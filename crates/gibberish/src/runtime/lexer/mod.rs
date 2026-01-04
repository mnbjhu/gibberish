pub mod edit;
pub mod pos;
mod regex;
mod res;
pub mod state;
pub mod token;

use std::cmp::max;

use crate::{
    lexer::RegexAst,
    runtime::{
        lexer::{pos::Pos, state::LexerState},
        parser::Parser,
    },
};

#[derive(Default)]
pub struct Lexer {
    pub tokens: Vec<LexerToken>,
}

pub struct LexerToken {
    pub id: u32,
    pub name: String,
    pub regex: RegexAst,
}

impl Lexer {
    pub fn get_parser(&self, name: &str) -> Option<Parser> {
        self.tokens.iter().find_map(|it| {
            if it.name == name {
                Some(Parser::Just(it.id))
            } else {
                None
            }
        })
    }

    pub fn lex(&self, text: String) -> LexerState {
        let err_id = self.tokens.len() as u32;
        let mut offset = Pos::zero();
        let mut state = LexerState {
            text,
            max_peak: 0,
            tokens: vec![],
        };
        while let Some(tok) = state.lex_token(offset, self) {
            offset += tok.relative_pos;
            if tok.kind == err_id
                && let Some(last) = state.tokens.last_mut()
                && last.kind == err_id
            {
                last.lookahead = max(last.lookahead.saturating_sub(1), tok.lookahead);
                last.relative_pos += tok.relative_pos;
            } else {
                state.tokens.push(tok);
            }
        }
        state
    }
}
