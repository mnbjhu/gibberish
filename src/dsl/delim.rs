use crate::parser::{lang::Lang, res::PRes, state::ParserState};

use super::Parser;

#[derive(Clone)]
pub struct Delim<L: Lang> {
    pub start: Box<Parser<L>>,
    pub end: Box<Parser<L>>,
    pub inner: Box<Parser<L>>,
}

impl<L: Lang> Delim<L> {
    pub fn parse(&self, state: &mut ParserState<L>) -> PRes {
        let start = self.start.parse(state);
        if start != PRes::Ok {
            return start;
        };
        loop {
            let res = self.inner.parse(state);
            match res {
                PRes::Err => {
                    state.bump_err();
                }
                PRes::Break(_) => return res,
                PRes::Ok => break,
            }
        }

        state.push_delim(self.end.as_ref().clone());
    }
    pub fn peak(&self, state: &ParserState<L>) -> PRes {
        self.start.peak(state)
    }
}
