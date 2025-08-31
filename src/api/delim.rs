use tracing::warn;

use crate::parser::{err::Expected, lang::Lang, res::PRes, state::ParserState};

use super::Parser;

#[derive(Debug, Clone)]
pub struct Delim<L: Lang> {
    start: Box<Parser<L>>,
    end: Box<Parser<L>>,
    inner: Box<Parser<L>>,
}

impl<L: Lang> Delim<L> {
    pub fn parse(&self, state: &mut ParserState<L>, recover: bool) -> PRes {
        let start = self.start.do_parse(state, recover);
        if start != PRes::Ok {
            warn!("Failed to parse delim");
            return start;
        };
        let _ = state.push_delim(Parser::clone(&self.end));
        let (inner, bumped) = state.try_parse(&self.inner, recover);
        if inner != PRes::Ok && !bumped {
            state.missing(&self.inner);
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
        let (end, bumped) = state.try_parse(&self.end, recover);
        if end != PRes::Ok && !bumped {
            state.missing(&self.end);
        }
        PRes::Ok
    }

    pub fn peak(&self, state: &ParserState<L>, recover: bool, offset: usize) -> PRes {
        self.start.peak(state, recover, offset)
    }

    pub fn expected(&self) -> Vec<Expected<L>> {
        self.start.expected()
    }
}

impl<L: Lang> Parser<L> {
    pub fn delim_by(self, start: Parser<L>, end: Parser<L>) -> Parser<L> {
        Parser::Delim(Delim {
            start: Box::new(start),
            end: Box::new(end),
            inner: Box::new(self),
        })
    }
}
