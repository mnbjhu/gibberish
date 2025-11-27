use std::fmt::Display;

use gibberish_core::{
    err::Expected,
    lang::{CompiledLang, Lang},
};

use crate::api::ptr::{ParserCache, ParserIndex};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Named {
    pub inner: ParserIndex,
    pub name: u32,
}

impl Named {
    pub fn expected(&self) -> Vec<Expected<CompiledLang>> {
        vec![Expected::Label(self.name.clone())]
    }
}

impl ParserIndex {
    pub fn named(self, name: u32, cache: &mut ParserCache) -> ParserIndex {
        Parser::Named(Named { inner: self, name }).cache(cache)
    }
}

impl Display for Named {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "Named({})", self.name)
    }
}
