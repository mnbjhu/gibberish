use std::fmt::Display;

use gibberish_tree::{err::Expected, lang::Lang};

use crate::api::ptr::{ParserCache, ParserIndex};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Named<L: Lang> {
    pub inner: ParserIndex<L>,
    pub name: L::Syntax,
}

impl<'a, L: Lang> Named<L> {
    pub fn expected(&self) -> Vec<Expected<L>> {
        vec![Expected::Label(self.name.clone())]
    }
}

impl<L: Lang> ParserIndex<L> {
    pub fn named(self, name: L::Syntax, cache: &mut ParserCache<L>) -> ParserIndex<L> {
        Parser::Named(Named { inner: self, name }).cache(cache)
    }
}

impl<L: Lang> Display for Named<L> {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "Named({})", self.name)
    }
}
