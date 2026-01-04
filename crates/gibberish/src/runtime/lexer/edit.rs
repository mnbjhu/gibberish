use std::ops::Range;

use crate::runtime::lexer::{Lexer, state::LexerState, token::Tok};

pub struct TextEdit {
    pub remove: Range<usize>,
    pub text: String,
}

pub struct TokenEdit {
    pub remove: Range<usize>,
    pub insert: usize,
}

impl TextEdit {
    fn change(&self) -> isize {
        isize::try_from(self.text.len()).unwrap() - isize::try_from(self.remove.len()).unwrap()
    }
}

impl LexerState {
    pub fn edit(&mut self, lexer: &Lexer, edit: &TextEdit) -> TokenEdit {
        self.text.replace_range(edit.remove.clone(), &edit.text);
        let mut new: Vec<Tok> = vec![];
        let mut offset = 0;
        let mut index = 0;
        for t in &self.tokens {
            let lookahead = offset + t.len + t.lookahead;
            if lookahead > edit.remove.start {
                break;
            } else {
                index += 1;
                offset += t.len;
                new.push(*t);
            }
        }
        let start = new.len();
        let rest = self.tokens[index..].to_vec();
        let mut rest_iter = rest.into_iter();
        let mut after_edit_offset = isize::try_from(offset).unwrap() + edit.change();
        let mut removed = 0;
        let mut insert = 0;
        let edit_end = edit.remove.end + edit.text.len() - edit.remove.len();
        'outer: loop {
            let ioffset = isize::try_from(offset).unwrap();
            while after_edit_offset < ioffset {
                let Some(next) = rest_iter.next() else {
                    break 'outer;
                };
                removed += 1;
                after_edit_offset += isize::try_from(next.len).unwrap();
            }
            if after_edit_offset == ioffset && offset >= edit_end {
                let end = new.len();
                new.extend(rest_iter);
                let new_len = new.len();
                self.tokens = new;
                return TokenEdit {
                    remove: start..start + removed,
                    insert,
                };
            }
            if let Some(tok) = self.lex_token(offset, lexer) {
                insert += 1;
                offset += tok.len;
                new.push(tok);
            }
        }
        while let Some(tok) = self.lex_token(offset, lexer) {
            insert += 1;
            offset += tok.len;
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
        runtime::lexer::{Lexer, LexerToken, edit::TextEdit, token::Tok},
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
        assert_eq!(res.tokens[0].len, 5);
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
        assert_eq!(res.tokens[0].len, 5);
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
        assert_eq!(res.tokens[0].len, 2);
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
                len: 1,
                lookahead: 1
            }
        );
        assert_eq!(
            res.tokens[1],
            Tok {
                kind: IDENT,
                len: 5,
                lookahead: 1
            }
        );

        assert_eq!(
            res.tokens[2],
            Tok {
                kind: WHITESPACE,
                len: 1,
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
                len: 1,
                lookahead: 1
            }
        );
        assert_eq!(
            res.tokens[1],
            Tok {
                kind: IDENT,
                len: 2,
                lookahead: 1
            }
        );

        assert_eq!(
            res.tokens[2],
            Tok {
                kind: WHITESPACE,
                len: 1,
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
