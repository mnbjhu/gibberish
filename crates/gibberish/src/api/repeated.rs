use crate::{api::Parser, parser::lang::Lang};

use crate::{
    api::ptr::{ParserCache, ParserIndex},
    parser::{err::Expected, res::PRes, state::ParserState},
};

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Repeated<L: Lang>(ParserIndex<L>);

impl<'a, L: Lang> Repeated<L> {
    pub fn parse(&'a self, state: &mut ParserState<'a, L>, recover: bool) -> PRes {
        let item_index = state.push_delim(self.0.clone());
        let start = self.0.get_ref(state.cache).do_parse(state, recover);
        if !start.is_ok() {
            state.pop_delim();
            return start;
        }
        loop {
            let res = self.0.get_ref(state.cache).do_parse(state, recover);
            match res {
                PRes::Ok => {
                    continue;
                }
                PRes::Err => {
                    state.bump_err(self.0.get_ref(state.cache).expected(state));
                }
                PRes::Break(id) if id == item_index => {
                    panic!("Break at repeated")
                }
                PRes::Eof => {
                    break;
                }
                PRes::Break(index) => {
                    assert!(index <= item_index);
                    break;
                }
            }
        }
        state.pop_delim();
        PRes::Ok
    }

    pub fn peak(&'a self, state: &ParserState<'a, L>, recover: bool, offset: usize) -> PRes {
        self.0.get_ref(state.cache).peak(state, recover, offset)
    }

    pub fn expected(&self, state: &ParserState<'a, L>) -> Vec<Expected<L>> {
        self.0.get_ref(state.cache).expected(state)
    }
}

impl<L: Lang> ParserIndex<L> {
    pub fn repeated(self, cache: &mut ParserCache<L>) -> ParserIndex<L> {
        Parser::Repeated(Repeated(self)).cache(cache)
    }
}
