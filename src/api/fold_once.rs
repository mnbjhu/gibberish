use crate::{
    api::ptr::{ParserCache, ParserIndex},
    parser::{err::Expected, lang::Lang, res::PRes, state::ParserState},
};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct FoldOnce<L: Lang> {
    name: L::Syntax,
    first: ParserIndex<L>,
    next: ParserIndex<L>,
}

impl<'a, L: Lang> FoldOnce<L> {
    pub fn parse(&'a self, state: &mut ParserState<'a, L>, recover: bool) -> PRes {
        state.enter(self.name.clone());
        let first = self.first.get_ref(state.cache).do_parse(state, recover);
        if first.is_err() {
            state.disolve_name();
            return first;
        }
        if self
            .next
            .get_ref(state.cache)
            .peak(state, recover, state.after_skip())
            .is_err()
        {
            state.disolve_name();
            return PRes::Ok;
        } else {
            self.next.get_ref(state.cache).do_parse(state, recover);
        }
        state.exit();
        PRes::Ok
    }

    pub fn peak(&'a self, state: &ParserState<'a, L>, recover: bool, offset: usize) -> PRes {
        self.first.get_ref(state.cache).peak(state, recover, offset)
    }

    pub fn expected(&self, state: &ParserState<'a, L>) -> Vec<Expected<L>> {
        self.first.get_ref(state.cache).expected(state)
    }
}

impl<L: Lang> ParserIndex<L> {
    pub fn fold_once(
        self,
        name: L::Syntax,
        next: ParserIndex<L>,
        cache: &mut ParserCache<L>,
    ) -> ParserIndex<L> {
        Parser::FoldOnce(FoldOnce {
            name,
            first: self,
            next,
        })
        .cache(cache)
    }
}
