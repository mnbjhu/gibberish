use std::ops::Range;

use lsp_types::Position;
use tracing::debug;

use crate::runtime::lexer::{Lexer, pos::Pos, state::LexerState, token::Tok};

#[derive(Debug)]
pub struct TextEdit {
    pub remove: Range<usize>,
    pub text: String,
}

#[derive(Debug)]
pub struct TokenEdit {
    pub remove: Range<usize>,
    pub insert: usize,
}

impl TextEdit {
    pub fn change(&self) -> isize {
        isize::try_from(self.text.len()).unwrap() - isize::try_from(self.remove.len()).unwrap()
    }
}

impl TokenEdit {
    pub fn change(&self) -> isize {
        isize::try_from(self.insert).unwrap() - isize::try_from(self.remove.len()).unwrap()
    }
}

impl Pos {
    fn less_than(&self, other: &Position) -> bool {
        if self.line as u32 == other.line {
            (self.char as u32) < other.character
        } else {
            (self.line as u32) < other.line
        }
    }
}

impl LexerState {
    pub fn offset_from_position(&self, lsp_pos: &Position) -> usize {
        let mut pos = Pos::zero();
        for tok in &self.tokens {
            if !(pos + tok.relative_pos).less_than(lsp_pos) {
                while pos.less_than(lsp_pos) {
                    pos += match self.text.chars().nth(pos.offset).unwrap() {
                        '\n' => Pos::newline(),
                        _ => Pos::non_newline(),
                    }
                }
                return pos.offset;
            }
            pos += tok.relative_pos;
        }
        panic!("Outside of text")
    }

    pub fn edit(&mut self, lexer: &Lexer, edit: &TextEdit) -> TokenEdit {
        self.text.replace_range(edit.remove.clone(), &edit.text);
        let mut new: Vec<Tok> = vec![];
        let mut pos = Pos::zero();
        let mut index = 0;
        for t in &self.tokens {
            let lookahead = pos.offset + t.relative_pos.offset + t.lookahead;
            if lookahead > edit.remove.start {
                break;
            } else {
                index += 1;
                pos += t.relative_pos;
                new.push(*t);
            }
        }
        let start = new.len();
        let rest = self.tokens[index..].to_vec();
        let mut rest_iter = rest.into_iter();
        let mut after_edit_offset = isize::try_from(pos.offset).unwrap() + edit.change();
        let mut removed = 0;
        let mut insert = 0;
        let edit_end = edit.remove.end + edit.text.len() - edit.remove.len();
        'outer: loop {
            let ioffset = isize::try_from(pos.offset).unwrap();
            while after_edit_offset < ioffset {
                let Some(next) = rest_iter.next() else {
                    break 'outer;
                };
                removed += 1;
                after_edit_offset += isize::try_from(next.relative_pos.offset).unwrap();
            }
            if after_edit_offset == ioffset && pos.offset >= edit_end {
                let end = new.len();
                new.extend(rest_iter);
                let new_len = new.len();
                self.tokens = new;
                return TokenEdit {
                    remove: start..start + removed,
                    insert,
                };
            }
            if let Some(tok) = self.lex_token(pos, lexer) {
                insert += 1;
                pos += tok.relative_pos;
                new.push(tok);
            }
        }
        while let Some(tok) = self.lex_token(pos, lexer) {
            insert += 1;
            pos += tok.relative_pos;
            new.push(tok);
        }
        let old_len = self.tokens.len();
        self.tokens = new;
        TokenEdit {
            remove: start..old_len,
            insert,
        }
    }
}

mod tests {
    use crate::{
        lexer::{RegexAst, seq::parse_seq},
        runtime::lexer::{Lexer, LexerToken, edit::TextEdit, pos::Pos, token::Tok},
    };

    const WHITESPACE: u32 = 0;
    const STRING: u32 = 1;
    const LET: u32 = 2;
    const EQ: u32 = 3;
    const IDENT: u32 = 4;

    fn lexer() -> Lexer {
        Lexer {
            tokens: vec![
                (LexerToken {
                    id: LET,
                    name: "let".to_string(),
                    regex: parse_seq("(let)[^a-zA-Z0-9]", &mut 0).unwrap(),
                }),
                (LexerToken {
                    id: IDENT,
                    regex: parse_seq("[a-zA-Z][a-zA-Z0-9]+", &mut 0).unwrap(),
                    name: "ident".to_string(),
                }),
                (LexerToken {
                    id: STRING,
                    regex: parse_seq("\"[^\"]*\"", &mut 0).unwrap(),
                    name: "string".to_string(),
                }),
                (LexerToken {
                    id: EQ,
                    regex: parse_seq("=", &mut 0).unwrap(),
                    name: "eq".to_string(),
                }),
                (LexerToken {
                    id: WHITESPACE,
                    regex: parse_seq("\\s+", &mut 0).unwrap(),
                    name: "whitespace".to_string(),
                }),
            ],
        }
    }

    #[test]
    fn edit_empty() {
        let lexer = lexer();
        let mut res = lexer.lex(r#""#.to_string());
        assert_eq!(res.tokens.len(), 0);
        let edit = res.edit(
            &lexer,
            &TextEdit {
                remove: 0..0,
                text: "hello".to_string(),
            },
        );
        assert_eq!(res.tokens.len(), 1);
        assert_eq!(res.tokens[0].kind, IDENT);
        assert_eq!(res.tokens[0].relative_pos.offset, 5);
        assert_eq!(res.tokens[0].lookahead, 1);

        assert_eq!(edit.remove, 0..0);
        assert_eq!(edit.insert, 1);
    }

    #[test]
    fn edit_one() {
        let lexer = lexer();
        let mut res = lexer.lex(r#"hello"#.to_string());

        assert_eq!(res.tokens.len(), 1);
        assert_eq!(res.tokens[0].kind, IDENT);
        assert_eq!(res.tokens[0].relative_pos.offset, 5);
        assert_eq!(res.tokens[0].lookahead, 1);

        let edit = res.edit(
            &lexer,
            &TextEdit {
                remove: 1..5,
                text: "i".to_string(),
            },
        );

        assert_eq!(res.text, "hi");
        assert_eq!(res.tokens.len(), 1);
        assert_eq!(res.tokens[0].kind, IDENT);
        assert_eq!(res.tokens[0].relative_pos.offset, 2);
        assert_eq!(res.tokens[0].lookahead, 1);

        assert_eq!(edit.remove, 0..1);
        assert_eq!(edit.insert, 1);
    }

    #[test]
    fn edit_middle() {
        let lexer = lexer();
        let mut res = lexer.lex(r#" hello "#.to_string());

        assert_eq!(res.tokens.len(), 3);
        assert_eq!(
            res.tokens[0],
            Tok {
                kind: WHITESPACE,
                relative_pos: Pos {
                    offset: 1,
                    char: 1,
                    line: 0
                },
                lookahead: 1
            }
        );
        assert_eq!(
            res.tokens[1],
            Tok {
                kind: IDENT,
                relative_pos: Pos {
                    offset: 5,
                    char: 5,
                    line: 0
                },
                lookahead: 1
            }
        );

        assert_eq!(
            res.tokens[2],
            Tok {
                kind: WHITESPACE,
                relative_pos: Pos {
                    offset: 1,
                    char: 1,
                    line: 0
                },
                lookahead: 1
            }
        );

        let edit = res.edit(
            &lexer,
            &TextEdit {
                remove: 2..6,
                text: "i".to_string(),
            },
        );

        assert_eq!(res.text, " hi ");

        assert_eq!(res.tokens.len(), 3);
        assert_eq!(
            res.tokens[0],
            Tok {
                kind: WHITESPACE,
                relative_pos: Pos {
                    offset: 1,
                    char: 1,
                    line: 0
                },
                lookahead: 1
            }
        );
        assert_eq!(
            res.tokens[1],
            Tok {
                kind: IDENT,
                relative_pos: Pos {
                    offset: 2,
                    char: 2,
                    line: 0
                },
                lookahead: 1
            }
        );

        assert_eq!(
            res.tokens[2],
            Tok {
                kind: WHITESPACE,
                relative_pos: Pos {
                    offset: 1,
                    char: 1,
                    line: 0
                },
                lookahead: 1
            }
        );

        assert_eq!(edit.insert, 1);
        assert_eq!(edit.remove, 1..2);
    }

    #[test]
    fn test_basic_edit() {
        let lexer = lexer();

        let mut res = lexer.lex(r#"let test = "hello""#.to_string());

        assert_eq!(res.tokens.len(), 7);

        assert_eq!(res.tokens[0].kind, LET);
        assert_eq!(res.tokens[1].kind, WHITESPACE);
        assert_eq!(res.tokens[2].kind, IDENT);
        assert_eq!(res.tokens[3].kind, WHITESPACE);
        assert_eq!(res.tokens[4].kind, EQ);
        assert_eq!(res.tokens[5].kind, WHITESPACE);
        assert_eq!(res.tokens[6].kind, STRING);

        let edit = res.edit(
            &lexer,
            &TextEdit {
                remove: 4..10,
                text: "xy".to_string(),
            },
        );

        assert_eq!(res.text, r#"let xy "hello""#);

        assert_eq!(res.tokens.len(), 5);
        assert_eq!(res.tokens[0].kind, LET);
        assert_eq!(res.tokens[1].kind, WHITESPACE);
        assert_eq!(res.tokens[2].kind, IDENT);
        assert_eq!(res.tokens[3].kind, WHITESPACE);
        assert_eq!(res.tokens[4].kind, STRING);

        // REMOVE WS, IDENT, WS, EQ
        // INSERT WS, IDENT
        assert_eq!(edit.remove, 1..5);
        assert_eq!(edit.insert, 2);
    }
}
