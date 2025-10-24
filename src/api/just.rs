use std::fmt::{Display, Write};

use crate::{
    api::ptr::{ParserCache, ParserIndex},
    parser::{err::Expected, lang::Lang, res::PRes, state::ParserState},
};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Just<L: Lang>(pub L::Token);

impl<L: Lang> Just<L> {
    pub fn parse(&self, state: &mut ParserState<L>) -> PRes {
        let Some(tok) = state.current() else {
            return PRes::Eof;
        };
        if tok.kind == self.0 {
            state.bump();
            PRes::Ok
        } else if let Some(pos) = state.try_delim() {
            PRes::Break(pos)
        } else {
            // state.bump_err(self.expected());
            PRes::Err
        }
    }

    pub fn peak(&self, state: &ParserState<L>, recover: bool, offset: usize) -> PRes {
        let Some(tok) = state.at_offset(offset) else {
            return PRes::Eof;
        };
        if tok.kind == self.0 {
            return PRes::Ok;
        } else if recover && let Some(pos) = state.try_delim() {
            return PRes::Break(pos);
        }
        PRes::Err
    }

    pub fn expected(&self) -> Vec<Expected<L>> {
        vec![Expected::Token(self.0.clone())]
    }
}

pub fn just<L: Lang>(tok: L::Token, cache: &mut ParserCache<L>) -> ParserIndex<L> {
    let p = Parser::Just(Just(tok));
    p.cache(cache)
}

impl<L: Lang> Display for Just<L> {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "Just({})", self.0)
    }
}
