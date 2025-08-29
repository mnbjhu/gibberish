use tracing::warn;

use crate::parser::{err::Expected, lang::Lang, res::PRes, state::ParserState};

use super::{Parser, just::just};

#[derive(Debug, Clone)]
pub struct Delim<L: Lang> {
    start: L::Kind,
    end: L::Kind,
    inner: Box<Parser<L>>,
}

impl<L: Lang> Delim<L> {
    pub fn parse(&self, state: &mut ParserState<L>, recover: bool) -> PRes {
        let start = just(self.start).do_parse(state, recover);
        if start != PRes::Ok {
            warn!("Failed to parse delim");
            return start;
        };
        let index = state.push_delim(self.end);
        let inner = state.try_parse(&self.inner, recover);
        if inner == PRes::Break(index) {
            state.missing(&self.inner);
            just(self.end).do_parse(state, recover);
            return PRes::Ok;
        }
        if inner != PRes::Ok {
            state.pop_delim();
            return PRes::Ok;
        }
        let end = state.try_parse(&just(self.end), recover);
        if end != PRes::Ok {
            state.missing(&just(self.end));
        }
        state.pop_delim();
        PRes::Ok
    }

    pub fn expected(&self) -> Vec<Expected<L>> {
        vec![Expected::Token(self.start)]
    }
}

impl<L: Lang> Parser<L> {
    pub fn delim_by(self, start: L::Kind, end: L::Kind) -> Parser<L> {
        Parser::Delim(Delim {
            start,
            end,
            inner: Box::new(self),
        })
    }
}
