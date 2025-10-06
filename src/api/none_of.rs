use crate::parser::{err::Expected, lang::Lang, res::PRes, state::ParserState};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct NoneOf<L: Lang>(Vec<L::Token>);

impl<L: Lang> NoneOf<L> {
    pub fn parse(&self, state: &mut ParserState<L>) -> PRes {
        let Some(tok) = state.current() else {
            return PRes::Eof;
        };
        if !self.0.contains(&tok.kind) {
            PRes::Ok
        } else if let Some(pos) = state.try_delim() {
            PRes::Break(pos)
        } else {
            // state.bump_err(self.expected());
            PRes::Err
        }
    }

    pub fn peak(&self, state: &ParserState<L>, recover: bool, offset: usize) -> PRes {
        let Some(tok) = state.current() else {
            return PRes::Eof;
        };
        if !self.0.contains(&tok.kind) {
            PRes::Ok
        } else if let Some(pos) = state.try_delim() {
            PRes::Break(pos)
        } else {
            // state.bump_err(self.expected());
            PRes::Err
        }
    }

    pub fn expected(&self) -> Vec<Expected<L>> {
        vec![] // TODO: Think about expected here
    }
}

pub fn none_of<L: Lang>(toks: Vec<L::Token>) -> Parser<L> {
    Parser::NoneOf(NoneOf(toks))
}
