use std::fmt::Display;

use crate::parser::{err::Expected, lang::Lang, res::PRes, state::ParserState};

use super::Parser;

#[derive(Debug, Clone)]
pub struct Just<'src, L: Lang<'src>>(L::Token);

impl<'src, L: Lang<'src>> Just<'src, L> {
    pub fn parse(&self, state: &mut ParserState<'src, L>) -> PRes {
        let Some(tok) = state.current() else {
            return PRes::Eof;
        };
        if tok.kind == self.0 {
            state.bump();
            PRes::Ok
        } else if let Some(pos) = state.try_delim() {
            PRes::Break(pos)
        } else {
            state.bump_err(self.expected());
            PRes::Err
        }
    }

    pub fn peak(&self, state: &ParserState<'src, L>, recover: bool) -> PRes {
        let Some(tok) = state.current() else {
            return PRes::Eof;
        };
        if tok.kind == self.0 {
            return PRes::Ok;
        } else if !recover {
            if let Some(pos) = state.try_delim() {
                return PRes::Break(pos);
            }
        }
        PRes::Err
    }

    pub fn expected(&self) -> Vec<Expected<'src, L>> {
        vec![Expected::Token(self.0.clone())]
    }
}

pub fn just<'src, L: Lang<'src>>(tok: L::Token) -> Parser<'src, L> {
    Parser::Just(Just(tok))
}

impl<'src, L: Lang<'src>> Display for Just<'src, L> {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "Just({})", self.0)
    }
}
