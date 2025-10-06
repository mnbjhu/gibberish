use tracing::warn;

use crate::{
    api::ptr::{ParserCache, ParserIndex},
    parser::{err::Expected, lang::Lang, res::PRes, state::ParserState},
};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Delim<L: Lang> {
    start: ParserIndex<L>,
    end: ParserIndex<L>,
    inner: ParserIndex<L>,
}

impl<'a, L: Lang> Delim<L> {
    pub fn parse(&'a self, state: &mut ParserState<'a, L>, recover: bool) -> PRes {
        let start = self.start.get_ref(state.cache).do_parse(state, recover);
        if start != PRes::Ok {
            warn!("Failed to parse delim");
            return start;
        };
        let _ = state.push_delim(self.end);
        let (inner, bumped) = state.try_parse(self.inner.get_ref(state.cache), recover);
        if inner != PRes::Ok && !bumped {
            state.missing(self.inner.get_ref(state.cache));
        }
        state.pop_delim();
        // if inner == PRes::Break(index) {
        //     if !bumped {
        //         state.missing(&self.inner);
        //     }
        //     state.pop_delim();
        //     self.end.do_parse(state, recover);
        //     return PRes::Ok;
        // }
        let (end, bumped) = state.try_parse(self.end.get_ref(state.cache), recover);
        if end != PRes::Ok && !bumped {
            state.missing(self.end.get_ref(state.cache));
        }
        PRes::Ok
    }

    pub fn peak(&'a self, state: &ParserState<'a, L>, recover: bool, offset: usize) -> PRes {
        self.start.get_ref(state.cache).peak(state, recover, offset)
    }

    pub fn expected(&self, state: &ParserState<'a, L>) -> Vec<Expected<L>> {
        self.start.get_ref(state.cache).expected(state)
    }
}

impl<L: Lang> ParserIndex<L> {
    pub fn delim_by(
        self,
        start: ParserIndex<L>,
        end: ParserIndex<L>,
        cache: &mut ParserCache<L>,
    ) -> ParserIndex<L> {
        Parser::Delim(Delim {
            start,
            end,
            inner: self,
        })
        .cache(cache)
    }
}
