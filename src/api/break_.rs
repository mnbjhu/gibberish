use crate::{
    api::ptr::{ParserCache, ParserIndex},
    parser::{err::Expected, lang::Lang, res::PRes, state::ParserState},
};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Break<L: Lang> {
    inner: ParserIndex<L>,
    break_: ParserIndex<L>,
}

impl<'a, L: Lang> Break<L> {
    pub fn parse(&'a self, state: &mut ParserState<'a, L>, recover: bool) -> PRes {
        let index = state.push_delim(self.break_);
        let mut res = self.inner.get_ref(state.cache).do_parse(state, recover);
        if let PRes::Break(i) = res
            && index == i
        {
            res = PRes::Ok
        }
        state.pop_delim();
        res
    }

    pub fn peak(&'a self, state: &ParserState<L>, recover: bool, offset: usize) -> PRes {
        self.inner.get_ref(state.cache).peak(state, recover, offset)
    }

    pub fn expected(&self, state: &ParserState<'a, L>) -> Vec<Expected<L>> {
        self.inner.get_ref(state.cache).expected(state)
    }
}

impl<L: Lang> ParserIndex<L> {
    pub fn break_at(self, parser: ParserIndex<L>, cache: &mut ParserCache<L>) -> ParserIndex<L> {
        Parser::Break(Break {
            inner: self,
            break_: parser,
        })
        .cache(cache)
    }
}
