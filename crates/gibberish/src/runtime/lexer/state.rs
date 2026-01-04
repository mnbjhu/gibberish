use crate::runtime::lexer::{Lexer, LexerToken, pos::Pos, res::LexResult, token::Tok};

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

    pub fn get_char_with_pos(&mut self, offset: usize) -> (Option<char>, Pos) {
        if offset > self.max_peak {
            self.max_peak = offset;
        }
        match self.text.chars().nth(offset) {
            Some('\n') => (Some('\n'), Pos::newline()),
            Some(char) => (Some(char), Pos::non_newline()),
            None => (None, Pos::zero()),
        }
    }

    pub fn cmp_str(&mut self, mut offset: usize, text: &str) -> Option<Pos> {
        let mut pos = Pos::zero();
        for char in text.chars() {
            if let Some(c) = self.get_char(offset)
                && c == char
            {
                if c == '\n' {
                    pos.line += 1;
                    pos.char = 0;
                } else {
                    pos.char += 1;
                }
                offset += 1;
            } else {
                return None;
            }
        }
        Some(pos)
    }

    pub fn lex_token(&mut self, pos: Pos, lexer: &Lexer) -> Option<Tok> {
        self.max_peak = pos.offset;
        let err_id = lexer.tokens.len();
        if pos.offset >= self.text.len() {
            return None;
        }
        for LexerToken { id, regex, .. } in &lexer.tokens {
            if let Some(LexResult { matched, group }) = regex.lex(pos, self) {
                let captured = if let Some(group) = group {
                    group
                } else {
                    matched
                };
                let lookahead = 1 + self.max_peak - captured.offset - pos.offset;
                return Some(Tok {
                    kind: *id,
                    relative_pos: captured,
                    lookahead,
                });
            }
        }
        let lookahead = self.max_peak - pos.offset;
        Some(Tok {
            kind: err_id as u32,
            relative_pos: self.get_char_with_pos(pos.offset).1,
            lookahead,
        })
    }

    // pub fn edit(&self, existing: Vec<Tok>, edit: &TextEdit) -> Vec<Tok> {
    //     let mut offset = 0;
    //     let mut existing = existing.into_iter();
    // }
}
