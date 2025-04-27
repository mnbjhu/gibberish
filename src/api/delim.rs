use tracing::warn;

use crate::parser::{err::Expected, lang::Lang, res::PRes, state::ParserState};

use super::Parser;

#[derive(Debug, Clone)]
pub struct Delim<'src, L: Lang<'src>> {
    start: Box<Parser<'src, L>>,
    end: Box<Parser<'src, L>>,
    inner: Box<Parser<'src, L>>,
}

impl<'src, L: Lang<'src>> Delim<'src, L> {
    pub fn parse(&self, state: &mut ParserState<'src, L>, recover: bool) -> PRes {
        let start = self.start.do_parse(state, recover);
        if start != PRes::Ok {
            warn!("Failed to parse delim");
            return start;
        };
        let index = state.push_delim(Parser::clone(&self.end));
        let inner = state.try_parse(&self.inner, recover);
        if inner == PRes::Break(index) {
            state.missing(&self.inner);
            self.end.do_parse(state, recover);
            return PRes::Ok;
        }
        if inner != PRes::Ok {
            state.pop_delim();
            return PRes::Ok;
        }
        let end = state.try_parse(&self.end, recover);
        if end != PRes::Ok {
            state.pop_delim();
            return PRes::Ok;
        }
        state.pop_delim();
        PRes::Ok
    }

    pub fn peak(&self, state: &ParserState<'src, L>, recover: bool) -> PRes {
        self.start.peak(state, recover)
    }

    pub fn expected(&self) -> Vec<Expected<'src, L>> {
        self.start.expected()
    }
}

impl<'src, L: Lang<'src>> Parser<'src, L> {
    pub fn delim_by(self, start: Parser<'src, L>, end: Parser<'src, L>) -> Parser<'src, L> {
        Parser::Delim(Delim {
            start: Box::new(start),
            end: Box::new(end),
            inner: Box::new(self),
        })
    }
}
