use crate::{
    api::ptr::{ParserCache, ParserIndex},
    parser::{err::Expected, lang::Lang, res::PRes, state::ParserState},
};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq, Copy)]
pub struct Recursive<L: Lang>(pub ParserIndex<L>);

impl<'a, L: Lang> Recursive<L> {
    pub fn parse(&'a self, state: &mut ParserState<'a, L>, recover: bool) -> PRes {
        self.0.get_ref(state.cache).do_parse(state, recover)
    }

    pub fn peak(&'a self, state: &ParserState<'a, L>, recover: bool, offset: usize) -> PRes {
        self.0.get_ref(state.cache).peak(state, recover, offset)
    }

    pub fn expected(&self, state: &ParserState<'a, L>) -> Vec<Expected<L>> {
        self.0.get_ref(state.cache).expected(state)
    }
}

pub fn recursive<L: Lang>(
    mut builder: impl FnMut(ParserIndex<L>, &mut ParserCache<L>) -> ParserIndex<L>,
    cache: &mut ParserCache<L>,
) -> ParserIndex<L> {
    let index = ParserIndex::from(cache.parsers.len());
    cache
        .parsers
        .push(Parser::Rec(Recursive(ParserIndex::from(0))));
    let res = builder(index, cache);
    let Some(Parser::Rec(p)) = cache.parsers.get_mut(index.index) else {
        panic!()
    };
    p.0.index = res.index;
    index
}
