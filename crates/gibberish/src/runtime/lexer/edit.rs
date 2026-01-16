use std::ops::Range;

use lsp_types::Position;

use crate::runtime::lexer::{Lexer, pos::Pos, state::LexerState, token::Tok};

#[derive(Debug)]
pub struct TextEdit {
    pub remove: Range<usize>,
    pub text: String,
}

#[derive(Debug, Clone)]
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

    pub fn is_empty(&self) -> bool {
        self.remove.len() == 0 && self.insert == 0
    }

    pub fn reduce(&mut self, before: usize, after: usize) -> usize {
        if before == after {
            self.remove = self.remove.start..self.remove.start;
            self.insert = 0;
            return 0;
        }
        let edit_start = self.remove.start;
        let edit_end = self.remove.end;
        let next_token_start = after;
        let original_end_pos = if before <= edit_start {
            before
        } else if before <= edit_start + self.insert {
            edit_start
        } else {
            let past_insert = before - (edit_start + self.insert);
            edit_end + past_insert
        };

        if original_end_pos > next_token_start {
            let consumed = original_end_pos - next_token_start;
            self.remove = next_token_start..original_end_pos;
            if edit_end <= original_end_pos {
                self.insert = 0;
            } else {
                self.insert = self.insert.saturating_sub(consumed);
            }

            return consumed;
        }
        self.remove = self.remove.start..self.remove.start;
        self.insert = 0;
        0
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
        let mut start = new.len();
        let mut is_start = true;
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
                new.extend(rest_iter);
                self.tokens = new;
                return TokenEdit {
                    remove: start..start + removed,
                    insert,
                };
            }
            if let Some(tok) = self.lex_token(pos, lexer) {
                // if is_start && tok == self.tokens[index] {
                //     start += 1;
                // } else {
                //     is_start = false;
                // }
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
        runtime::lexer::{
            Lexer, LexerToken,
            edit::{TextEdit, TokenEdit},
            pos::Pos,
            token::Tok,
        },
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

    #[test]
    fn test_reduce_example() {
        // Test case from the user's example:
        // Original: ABCDEF -> tokens <ABC> (0..3) and <DEF> (3..6)
        // Edit: 1..2 -> XY (remove B, insert XY) -> AXYCDEF
        // First token becomes <AXYCD> (new size 5)
        // Original first token was ABC (size 3)
        // Need to find what edit remains for the second token
        //
        // After first token consumes AXYCD:
        // - Original positions consumed: 0, 2, 3 (A, C, D) + removed position 1 (B)
        // - The edit (remove B, insert XY) is fully within the first token
        // - D (original position 3) was consumed from the second token
        // - To transform DEF -> EF, we need: remove position 3..4 (D)

        let mut edit = TokenEdit {
            remove: 1..2,
            insert: 2,
        };

        // New token size 5, original token size 3
        // Consumed 1 char (D) from the next token
        let consumed = edit.reduce(5, 3);

        assert_eq!(consumed, 1);

        // The remaining edit should transform DEF -> EF
        // That means: remove position 3 (D), insert nothing
        assert_eq!(edit.remove, 3..4);
        assert_eq!(edit.insert, 0);
    }

    #[test]
    fn test_reduce_size_match() {
        // When before == after, the sizes match so we clear the edit
        let mut edit = TokenEdit {
            remove: 1..2,
            insert: 1,
        };

        let consumed = edit.reduce(3, 3);

        assert_eq!(consumed, 0);
        assert_eq!(edit.remove, 1..1);
        assert_eq!(edit.insert, 0);
        assert!(edit.is_empty());
    }

    #[test]
    fn test_reduce_no_overlap() {
        // Edit is before the token, so nothing gets consumed
        let mut edit = TokenEdit {
            remove: 0..1,
            insert: 2,
        };

        let consumed = edit.reduce(2, 3);

        assert_eq!(consumed, 0);
        assert_eq!(edit.remove, 0..0);
        assert_eq!(edit.insert, 0);
        assert!(edit.is_empty());
    }

    #[test]
    fn test_reduce_token_shrinks() {
        // Original: ABCDEF -> tokens <ABCD> (0..4) and <EF> (4..6)
        // Edit: 1..3 -> X (remove BC, insert X) -> AXDEF
        // First token becomes <AXD> (new size 3)
        // Original first token was ABCD (size 4)
        // Token shrunk! No consumption from next token.

        let mut edit = TokenEdit {
            remove: 1..3,
            insert: 1,
        };

        let consumed = edit.reduce(3, 4);

        // Token shrunk from 4 to 3, so no consumption from next token
        assert_eq!(consumed, 0);
        assert!(edit.is_empty());
    }

    #[test]
    fn test_reduce_pure_insertion() {
        // Original: ABCD -> tokens <AB> (0..2) and <CD> (2..4)
        // Edit: 1..1 -> XY (insert XY at position 1, remove nothing) -> AXYB CD
        // First token becomes <AXYB> (new size 4)
        // Original first token was AB (size 2)
        // Token grew by 2 (the insertion), no consumption from next token

        let mut edit = TokenEdit {
            remove: 1..1,
            insert: 2,
        };

        let consumed = edit.reduce(4, 2);

        // Grew by exactly the insertion size, so no consumption
        assert_eq!(consumed, 0);
        assert!(edit.is_empty());
    }

    #[test]
    fn test_reduce_pure_deletion() {
        // Original: ABCDEF -> tokens <ABCD> (0..4) and <EF> (4..6)
        // Edit: 1..3 -> (remove BC, insert nothing) -> ADEF
        // First token becomes <ADE> (new size 3)
        // Original first token was ABCD (size 4)
        //
        // What positions did <ADE> consume from the original?
        // Result[0] = A = Original[0]
        // Result[1] = D = Original[3] (BC was removed)
        // Result[2] = E = Original[4]
        // So we consumed Original[0, 3, 4], which includes position 4 from next token!

        let mut edit = TokenEdit {
            remove: 1..3,
            insert: 0,
        };

        let consumed = edit.reduce(3, 4);

        // We consumed 1 position (E at position 4) from the next token
        assert_eq!(consumed, 1);
        assert_eq!(edit.remove, 4..5);
        assert_eq!(edit.insert, 0);
    }

    #[test]
    fn test_reduce_edit_spans_token_boundary() {
        // Original: ABCDEF -> tokens <ABC> (0..3) and <DEF> (3..6)
        // Edit: 2..4 -> X (remove CD, insert X) -> ABXEF
        // First token becomes <ABX> (new size 3)
        // Original first token was ABC (size 3)
        // Sizes match! But the edit spans into the next token...
        // When sizes match, we clear the edit regardless

        let mut edit = TokenEdit {
            remove: 2..4,
            insert: 1,
        };

        let consumed = edit.reduce(3, 3);

        // Sizes match, so edit is cleared
        assert_eq!(consumed, 0);
        assert!(edit.is_empty());
    }

    #[test]
    fn test_reduce_consumes_entire_next_token() {
        // Original: ABCD -> tokens <AB> (0..2) and <CD> (2..4)
        // Edit: 1..2 -> XYZW (remove B, insert XYZW) -> AXYZWCD
        // First token becomes <AXYZWCD> (new size 7)
        // Original first token was AB (size 2)
        // Token consumed all of the next token!

        let mut edit = TokenEdit {
            remove: 1..2,
            insert: 4,
        };

        // before=7, after=2
        // original_end_pos = edit_end + (before - edit_start - insert) = 2 + (7 - 1 - 4) = 4
        // consumed = 4 - 2 = 2 (entire next token)
        let consumed = edit.reduce(7, 2);

        assert_eq!(consumed, 2);
        assert_eq!(edit.remove, 2..4);
        assert_eq!(edit.insert, 0);
    }

    #[test]
    fn test_reduce_edit_at_token_start() {
        // Original: ABCDEF -> tokens <ABC> (0..3) and <DEF> (3..6)
        // Edit: 0..1 -> XY (remove A, insert XY) -> XYBCDEF
        // First token becomes <XYBC> (new size 4)
        // Original first token was ABC (size 3)
        // Consumed 1 char from next token

        let mut edit = TokenEdit {
            remove: 0..1,
            insert: 2,
        };

        // before=4, after=3
        // original_end_pos = edit_end + (before - edit_start - insert) = 1 + (4 - 0 - 2) = 3
        // Wait, that's not consuming into next token...
        // Let me recalculate:
        // Result: XYBCDEF, first token is XYBC (positions 0-3)
        // Original positions consumed: 1,2,3 (B,C,D) - but A was removed
        // Actually: X,Y are inserted, B=orig[1], C=orig[2]
        // So consuming 4 chars means: X, Y (inserted), B (orig 1), C (orig 2)
        // original_end_pos = 3 (we consumed through orig position 2, exclusive end is 3)
        // Hmm, let me re-check the formula...
        // before (4) > edit_start (0) + insert (2) = 2? Yes
        // past_insert = 4 - 2 = 2
        // original_end_pos = edit_end (1) + past_insert (2) = 3
        // consumed = 3 - 3 = 0

        let consumed = edit.reduce(4, 3);

        // Actually this doesn't consume from next token
        assert_eq!(consumed, 0);
        assert!(edit.is_empty());
    }

    #[test]
    fn test_reduce_edit_at_token_end() {
        // Original: ABCDEF -> tokens <ABC> (0..3) and <DEF> (3..6)
        // Edit: 2..3 -> XY (remove C, insert XY) -> ABXYDEF
        // First token becomes <ABXYD> (new size 5)
        // Original first token was ABC (size 3)

        let mut edit = TokenEdit {
            remove: 2..3,
            insert: 2,
        };

        // before=5, after=3
        // before (5) > edit_start (2) + insert (2) = 4? Yes
        // past_insert = 5 - 4 = 1
        // original_end_pos = edit_end (3) + past_insert (1) = 4
        // consumed = 4 - 3 = 1
        let consumed = edit.reduce(5, 3);

        assert_eq!(consumed, 1);
        assert_eq!(edit.remove, 3..4);
        assert_eq!(edit.insert, 0);
    }

    #[test]
    fn test_reduce_within_insertion() {
        // Original: ABCDEF -> tokens <ABC> (0..3) and <DEF> (3..6)
        // Edit: 1..2 -> XXXX (remove B, insert XXXX) -> AXXXXCDEF
        // First token becomes <AXX> (new size 3, only consumes part of insertion)
        // Original first token was ABC (size 3)

        let mut edit = TokenEdit {
            remove: 1..2,
            insert: 4,
        };

        // before=3, after=3 -> sizes match!
        let consumed = edit.reduce(3, 3);

        assert_eq!(consumed, 0);
        assert!(edit.is_empty());
    }

    #[test]
    fn test_reduce_partial_insertion_consumed() {
        // Original: ABCDEF -> tokens <ABC> (0..3) and <DEF> (3..6)
        // Edit: 1..2 -> XXXX (remove B, insert XXXX) -> AXXXXCDEF
        // First token becomes <AXXXX> (new size 5, consumes all of insertion)
        // Original first token was ABC (size 3)
        // We're within the inserted content

        let mut edit = TokenEdit {
            remove: 1..2,
            insert: 4,
        };

        // before=5, after=3
        // before (5) <= edit_start (1) + insert (4) = 5? Yes, exactly equal
        // So we're at the edge of inserted content
        // original_end_pos = edit_start = 1? No wait, we need edit_end
        // Actually the condition is before <= edit_start + insert
        // 5 <= 1 + 4 = 5, so yes
        // original_end_pos = edit_start = 1
        // consumed = 1 - 3 = negative, so no consumption
        let consumed = edit.reduce(5, 3);

        assert_eq!(consumed, 0);
        assert!(edit.is_empty());
    }

    #[test]
    fn test_reduce_just_past_insertion() {
        // Original: ABCDEF -> tokens <ABC> (0..3) and <DEF> (3..6)
        // Edit: 1..2 -> XXXX (remove B, insert XXXX) -> AXXXXCDEF
        // First token becomes <AXXXXC> (new size 6)
        // Original first token was ABC (size 3)

        let mut edit = TokenEdit {
            remove: 1..2,
            insert: 4,
        };

        // before=6, after=3
        // before (6) > edit_start (1) + insert (4) = 5? Yes
        // past_insert = 6 - 5 = 1
        // original_end_pos = edit_end (2) + past_insert (1) = 3
        // consumed = 3 - 3 = 0
        let consumed = edit.reduce(6, 3);

        assert_eq!(consumed, 0);
        assert!(edit.is_empty());
    }

    #[test]
    fn test_reduce_multiple_iterations() {
        // Simulate iterating through multiple tokens
        // Original: ABCDEFGH -> tokens <AB> <CD> <EF> <GH>
        // Edit: 1..3 -> X (remove BCD, insert X) -> AXEFGH
        // After edit, let's say we get: <AXE> <FGH>

        let mut edit = TokenEdit {
            remove: 1..3,
            insert: 1,
        };

        // First token: <AXE> size 3, original <AB> size 2
        // before=3, after=2
        // before (3) > edit_start (1) + insert (1) = 2? Yes
        // past_insert = 3 - 2 = 1
        // original_end_pos = edit_end (3) + past_insert (1) = 4
        // consumed = 4 - 2 = 2
        let consumed1 = edit.reduce(3, 2);
        assert_eq!(consumed1, 2);
        assert_eq!(edit.remove, 2..4);
        assert_eq!(edit.insert, 0);

        // Now reduce again for next token
        // We consumed CD from original tokens <CD> and <EF>
        // The remaining edit is remove 2..4, insert 0
        // Second token: <FGH> size 3, original <EF> size 2
        // But wait, the edit remove 2..4 means we're removing from position 2..4
        // That was CD, which we already accounted for
        // For the second iteration, before=3, after=2
        let consumed2 = edit.reduce(3, 2);

        // The edit remove 2..4 with next token starting at 2
        // original_end_pos calculation: before=3, edit_start=2, edit_end=4, insert=0
        // before (3) <= edit_start (2)? No
        // before (3) <= edit_start (2) + insert (0) = 2? No
        // past_insert = 3 - 2 = 1
        // original_end_pos = 4 + 1 = 5
        // consumed = 5 - 2 = 3
        assert_eq!(consumed2, 3);
    }

    #[test]
    fn test_reduce_empty_edit() {
        // Start with an empty edit
        let mut edit = TokenEdit {
            remove: 5..5,
            insert: 0,
        };

        let consumed = edit.reduce(3, 3);
        assert_eq!(consumed, 0);
        assert!(edit.is_empty());

        // With different sizes but empty edit
        let mut edit2 = TokenEdit {
            remove: 5..5,
            insert: 0,
        };
        let consumed2 = edit2.reduce(4, 3);
        // Even with size mismatch, if edit is empty and at position 5,
        // we need to check if we consume into next token
        // before=4, after=3, edit_start=5, edit_end=5, insert=0
        // before (4) <= edit_start (5)? Yes
        // original_end_pos = before = 4
        // consumed = 4 - 3 = 1
        assert_eq!(consumed2, 1);
    }

    #[test]
    fn test_reduce_large_deletion_small_insertion() {
        // Original: ABCDEFGHIJ -> tokens <ABCDE> (0..5) and <FGHIJ> (5..10)
        // Edit: 2..8 -> X (remove CDEFGH, insert X) -> ABXIJ
        // First token becomes <ABX> (new size 3)
        // Original first token was ABCDE (size 5)
        // Token shrunk significantly

        let mut edit = TokenEdit {
            remove: 2..8,
            insert: 1,
        };

        let consumed = edit.reduce(3, 5);

        // before=3, after=5
        // before (3) <= edit_start (2)? No
        // before (3) <= edit_start (2) + insert (1) = 3? Yes
        // original_end_pos = edit_start = 2
        // consumed = 2 - 5 = negative, so 0
        assert_eq!(consumed, 0);
        assert!(edit.is_empty());
    }

    #[test]
    fn test_reduce_insertion_longer_than_token() {
        // Original: AB -> tokens <A> (0..1) and <B> (1..2)
        // Edit: 0..1 -> XXXXX (remove A, insert XXXXX) -> XXXXXB
        // First token becomes <XXXXX> (new size 5)
        // Original first token was A (size 1)
        // All growth is from insertion, no consumption from next token

        let mut edit = TokenEdit {
            remove: 0..1,
            insert: 5,
        };

        // before=5, after=1
        // before (5) <= edit_start (0) + insert (5) = 5? Yes
        // original_end_pos = edit_start = 0
        // consumed = 0 - 1 = negative, so 0
        let consumed = edit.reduce(5, 1);

        assert_eq!(consumed, 0);
        assert!(edit.is_empty());
    }

    #[test]
    fn test_reduce_boundary_exactly_at_edit_end() {
        // Original: ABCDEF -> tokens <ABC> (0..3) and <DEF> (3..6)
        // Edit: 1..3 -> XY (remove BC, insert XY) -> AXYDEF
        // First token becomes <AXY> (new size 3)
        // Original first token was ABC (size 3)
        // Sizes match exactly

        let mut edit = TokenEdit {
            remove: 1..3,
            insert: 2,
        };

        let consumed = edit.reduce(3, 3);

        assert_eq!(consumed, 0);
        assert!(edit.is_empty());
    }
}
