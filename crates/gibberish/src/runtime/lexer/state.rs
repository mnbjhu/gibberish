use crate::runtime::lexer::{Lexer, LexerToken, res::LexResult, token::Tok};

#[derive(Debug)]
pub struct LexerState {
    pub text: String,
    pub max_peak: usize,
    pub tokens: Vec<Tok>,
}

impl LexerState {
    pub fn get_char(&mut self, offset: usize) -> Option<char> {
        if offset > self.max_peak {
            self.max_peak = offset;
        }
        let res = self.text.chars().nth(offset);
        res
    }

    pub fn cmp_str(&mut self, mut offset: usize, text: &str) -> bool {
        for char in text.chars() {
            if let Some(c) = self.get_char(offset)
                && c == char
            {
                offset += 1;
            } else {
                return false;
            }
        }
        true
    }

    pub fn lex_token(&mut self, offset: usize, lexer: &Lexer) -> Option<Tok> {
        self.max_peak = offset;
        let err_id = lexer.tokens.len();
        if offset >= self.text.len() {
            return None;
        }
        for LexerToken { id, regex, .. } in &lexer.tokens {
            if let Some(LexResult { matched, group }) = regex.lex(offset, self) {
                let captured = if let Some(group) = group {
                    group
                } else {
                    matched
                };
                let lookahead = 1 + self.max_peak - captured - offset;
                return Some(Tok {
                    kind: *id,
                    len: captured,
                    lookahead,
                });
            }
        }
        let lookahead = self.max_peak - offset;
        Some(Tok {
            kind: err_id as u32,
            len: 1,
            lookahead,
        })
    }

    // pub fn edit(&self, existing: Vec<Tok>, edit: &TextEdit) -> Vec<Tok> {
    //     let mut offset = 0;
    //     let mut existing = existing.into_iter();
    // }
}
