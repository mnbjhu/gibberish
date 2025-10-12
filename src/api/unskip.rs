use crate::parser::{err::Expected, lang::Lang, res::PRes, state::ParserState};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct UnSkip<L: Lang> {
    token: L::Token,
    inner: Box<Parser<L>>,
}

impl<'a, L: Lang> UnSkip<L> {
    pub fn parse(&'a self, state: &mut ParserState<'a, L>, recover: bool) -> PRes {
        let removed = state.unskip(self.token.clone());
        let res = self.inner.do_parse(state, recover);
        if removed {
            state.skip(self.token.clone());
        }
        state.bump_skipped(); // TODO: Check this
        res
    }

    pub fn peak(&'a self, state: &ParserState<'a, L>, recover: bool, offset: usize) -> PRes {
        self.inner.peak(state, recover, offset)
    }

    pub fn expected(&self, state: &ParserState<'a, L>) -> Vec<Expected<L>> {
        self.inner.expected(state)
    }
}

impl<L: Lang> Parser<L> {
    pub fn unskip(self, token: L::Token) -> Parser<L> {
        Parser::UnSkip(UnSkip {
            token,
            inner: Box::new(self),
        })
    }
}
