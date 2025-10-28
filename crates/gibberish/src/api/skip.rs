use crate::{
    api::ptr::{ParserCache, ParserIndex},
    parser::{err::Expected, lang::Lang, res::PRes, state::ParserState},
};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Skip<L: Lang> {
    pub token: L::Token,
    pub inner: ParserIndex<L>,
}

impl<'a, L: Lang> Skip<L> {
    pub fn parse(&'a self, state: &mut ParserState<'a, L>, recover: bool) -> PRes {
        let added = state.skip(self.token.clone());
        state.bump_skipped();
        let res = self.inner.get_ref(state.cache).do_parse(state, recover);
        if added {
            state.unskip(self.token.clone());
        }
        res
    }

    pub fn peak(&'a self, state: &ParserState<'a, L>, recover: bool, offset: usize) -> PRes {
        self.inner.get_ref(state.cache).peak(state, recover, offset)
    }

    pub fn expected(&self, state: &ParserState<'a, L>) -> Vec<Expected<L>> {
        self.inner.get_ref(state.cache).expected(state)
    }
}

impl<L: Lang> ParserIndex<L> {
    pub fn skip(self, token: L::Token, cache: &mut ParserCache<L>) -> ParserIndex<L> {
        Parser::Skip(Skip { token, inner: self }).cache(cache)
    }
}
