use std::fmt::Display;

use crate::parser::{err::Expected, lang::Lang, res::PRes, state::ParserState};

use super::Parser;

#[derive(Debug, Clone)]
pub struct Named<L: Lang> {
    inner: Box<Parser<L>>,
    name: L::Kind,
}

impl<L: Lang> Named<L> {
    pub fn parse(&self, state: &mut ParserState<L>, recover: bool) -> PRes {
        let peak = self.peak(state, recover);
        if peak.is_err() {
            return peak;
        };
        state.enter(self.name.clone());
        let res = self.inner.do_parse(state, recover);
        state.exit();
        res
    }

    pub fn peak(&self, state: &ParserState<L>, recover: bool) -> PRes {
        self.inner.peak(state, recover)
    }

    pub fn expected(&self) -> Vec<Expected<L>> {
        vec![Expected::Token(self.name.clone())]
    }
}

impl<L: Lang> Parser<L> {
    pub fn named(self, name: L::Kind) -> Parser<L> {
        Parser::Named(Named {
            inner: Box::new(self),
            name,
        })
    }
}

impl<L: Lang> Display for Named<L> {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "Named({:?})", self.name)
    }
}
