use std::fmt::Display;

use crate::parser::{err::Expected, lang::Lang, res::PRes, state::ParserState};

use super::Parser;

#[derive(Clone)]
pub struct Named<L: Lang> {
    inner: Box<Parser<L>>,
    name: L::Syntax,
}

impl<L: Lang> Named<L> {
    pub fn parse(&self, state: &mut ParserState<L>) -> PRes {
        state.enter(self.name.clone());
        let res = self.inner.parse(state);
        state.exit();
        res
    }

    pub fn peak(&self, state: &ParserState<L>) -> PRes {
        self.inner.peak(state)
    }

    pub fn expected(&self) -> Vec<Expected<L>> {
        vec![Expected::Label(self.name.clone())]
    }
}

impl<L: Lang> Parser<L> {
    pub fn named(self, name: L::Syntax) -> Parser<L> {
        Parser::Named(Named {
            inner: Box::new(self),
            name,
        })
    }
}

impl<L: Lang> Display for Named<L> {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "Named({})", self.name)
    }
}
