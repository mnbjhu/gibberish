use std::fmt::Display;

use crate::{
    api::ptr::{ParserCache, ParserIndex},
    parser::{err::Expected, lang::Lang, res::PRes, state::ParserState},
};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Named<L: Lang> {
    inner: ParserIndex<L>,
    name: L::Syntax,
}

impl<'a, L: Lang> Named<L> {
    pub fn parse(&'a self, state: &mut ParserState<'a, L>, recover: bool) -> PRes {
        let peak = self.peak(state, recover, state.after_skip());
        if peak.is_err() {
            return peak;
        };
        state.enter(self.name.clone());
        let res = self.inner.get_ref(state.cache).do_parse(state, recover);
        state.exit();
        res
    }

    pub fn peak(&'a self, state: &ParserState<'a, L>, recover: bool, offset: usize) -> PRes {
        self.inner.get_ref(state.cache).peak(state, recover, offset)
    }

    pub fn expected(&self) -> Vec<Expected<L>> {
        vec![Expected::Label(self.name.clone())]
    }
}

impl<L: Lang> ParserIndex<L> {
    pub fn named(self, name: L::Syntax, cache: &mut ParserCache<L>) -> ParserIndex<L> {
        Parser::Named(Named { inner: self, name }).cache(cache)
    }
}

impl<L: Lang> Display for Named<L> {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "Named({})", self.name)
    }
}
