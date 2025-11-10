use crate::{
    api::ptr::{ParserCache, ParserIndex},
    parser::{err::Expected, lang::Lang, res::PRes, state::ParserState},
};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct UnSkip<L: Lang> {
    token: L::Token,
    inner: ParserIndex<L>,
}

impl<'a, L: Lang> UnSkip<L> {
    pub fn parse(&'a self, state: &mut ParserState<'a, L>, recover: bool) -> PRes {
        let removed = state.unskip(self.token.clone());
        let res = self.inner.get_ref(state.cache).do_parse(state, recover);
        if removed {
            state.skip(self.token.clone());
        }
        state.bump_skipped(); // TODO: Check this
        res
    }

    pub fn peak(&'a self, state: &ParserState<'a, L>, recover: bool, offset: usize) -> PRes {
        self.inner.get_ref(state.cache).peak(state, recover, offset)
    }

    pub fn expected(&self, cache: &ParserCache<L>) -> Vec<Expected<L>> {
        self.inner.get_ref(cache).expected(cache)
    }
}

impl<L: Lang> ParserIndex<L> {
    pub fn unskip(self, token: L::Token, cache: &mut ParserCache<L>) -> ParserIndex<L> {
        Parser::UnSkip(UnSkip { token, inner: self }).cache(cache)
    }
}
