use tracing::warn;

use crate::parser::{err::Expected, lang::Lang, res::PRes, state::ParserState};

use super::Parser;

#[derive(Clone)]
pub struct Delim<L: Lang> {
    start: Box<Parser<L>>,
    end: Box<Parser<L>>,
    inner: Box<Parser<L>>,
}

impl<L: Lang> Delim<L> {
    pub fn parse(&self, state: &mut ParserState<L>) -> PRes {
        let start = self.start.do_parse(state);
        if start != PRes::Ok {
            warn!("Failed to parse delim");
            return start;
        };
        state.push_delim(self.end.as_ref().clone());
        let inner = state.try_parse(self.inner.as_ref());
        if inner != PRes::Ok {
            state.pop_delim();
            return inner;
        }
        let end = state.try_parse(self.end.as_ref());
        if end != PRes::Ok {
            state.pop_delim();
            return end;
        }
        state.pop_delim();
        PRes::Ok
    }

    pub fn peak(&self, state: &ParserState<L>) -> PRes {
        self.start.peak(state)
    }

    pub fn expected(&self) -> Vec<Expected<L>> {
        self.inner.expected()
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
