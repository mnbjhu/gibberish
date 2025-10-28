use crate::{
    api::ptr::{ParserCache, ParserIndex},
    parser::{err::Expected, lang::Lang, res::PRes, state::ParserState},
};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Seq<L: Lang>(pub Vec<ParserIndex<L>>);

impl<'a, L: Lang> Seq<L> {
    pub fn parse(&self, state: &mut ParserState<L>, recover: bool) -> PRes {
        let start = self.peak(state, recover, state.after_skip());
        if start.is_err() {
            return start;
        }

        let first_index = state.recover_index();
        let last_index = first_index + self.0.len() - 2;

        for p in self.0[1..].iter().rev() {
            let _ = state.push_delim(p.clone());
        }
        let mut parsing_index = 0;
        loop {
            let p = self.0[parsing_index].clone();
            let (res, bumped) = state.try_parse(p.get_ref(state.cache), recover);
            match res {
                PRes::Break(index) if index < first_index => {
                    if !bumped {
                        state.missing(p.get_ref(state.cache));
                    }
                    for _ in parsing_index..self.0.len() - 2 {
                        state.pop_delim();
                    }
                    return PRes::Ok;
                }
                PRes::Break(index) => {
                    assert!(index <= last_index);
                    let new_index = last_index - index + 1;
                    for _ in parsing_index..new_index - 1 {
                        state.pop_delim();
                    }
                    state.missing(self.0[new_index - 1].get_ref(state.cache));
                    parsing_index = new_index;
                }
                PRes::Eof => {
                    state.missing(p.get_ref(state.cache));
                    for _ in parsing_index..self.0.len() - 2 {
                        state.pop_delim();
                    }
                    return PRes::Ok;
                }
                PRes::Ok => {
                    parsing_index += 1;
                    if parsing_index == self.0.len() {
                        return PRes::Ok;
                    } else {
                        state.pop_delim();
                    }
                }
                PRes::Err => return PRes::Ok,
            }
        }

        // for p in &self.0 {
        //     let (res, bumped) = state.try_parse(p.get_ref(state.cache), recover);
        //     match res {
        //         PRes::Break(_) => {
        //             if !bumped {
        //                 state.missing(p.get_ref(state.cache));
        //             }
        //             return PRes::Ok;
        //         }
        //         PRes::Ok => continue,
        //         PRes::Eof | PRes::Err => return PRes::Ok,
        //     }
        // }
    }

    pub fn peak(&self, state: &ParserState<L>, recover: bool, offset: usize) -> PRes {
        self.0
            .first()
            .expect("Seq should have at least one element")
            .get_ref(state.cache)
            .peak(state, recover, offset)
    }

    pub fn expected(&self, state: &ParserState<'a, L>) -> Vec<Expected<L>> {
        self.0
            .first()
            .expect("Seq should have at least one element")
            .get_ref(state.cache)
            .expected(state)
    }
}

pub fn seq<L: Lang>(parts: Vec<ParserIndex<L>>, cache: &mut ParserCache<L>) -> ParserIndex<L> {
    Parser::Seq(Seq(parts)).cache(cache)
}

impl<L: Lang> ParserIndex<L> {
    pub fn then(self, other: ParserIndex<L>, cache: &mut ParserCache<L>) -> ParserIndex<L> {
        if let Parser::Seq(seq) = self.get_mut(cache) {
            seq.0.push(other);
            self
        } else {
            seq(vec![self, other], cache)
        }
    }
}
