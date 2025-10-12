use crate::{
    api::{
        Parser,
        ptr::{ParserCache, ParserIndex},
    },
    parser::{err::Expected, lang::Lang, res::PRes, state::ParserState},
};

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Optional<L: Lang>(ParserIndex<L>);

impl<'a, L: Lang> Optional<L> {
    pub fn parse(&'a self, state: &mut ParserState<'a, L>, recover: bool) -> PRes {
        let res = self
            .0
            .get_ref(state.cache)
            .peak(state, recover, state.after_skip());
        if res != PRes::Ok {
            return PRes::Ok;
        }
        self.0.get_ref(state.cache).do_parse(state, recover);
        res
    }

    pub fn peak(&'a self, state: &ParserState<'a, L>, recover: bool, offset: usize) -> PRes {
        let res = self.0.get_ref(state.cache).peak(state, recover, offset);
        if res == PRes::Err {
            return PRes::Ok;
        }
        res
    }

    pub fn expected(&self, state: &ParserState<'a, L>) -> Vec<Expected<L>> {
        self.0.get_ref(state.cache).expected(state)
    }
}

impl<L: Lang> ParserIndex<L> {
    pub fn or_not(self, cache: &mut ParserCache<L>) -> ParserIndex<L> {
        Parser::Optional(Optional(self)).cache(cache)
    }
}
