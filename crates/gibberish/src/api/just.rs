use std::fmt::{Display, Write};

use gibberish_core::{
    err::Expected,
    lang::{CompiledLang, Lang},
};

use crate::api::ptr::{ParserCache, ParserIndex};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Just(pub u32);

impl Just {
    pub fn expected(&self) -> Vec<Expected<CompiledLang>> {
        vec![Expected::Token(self.0.clone())]
    }
}

pub fn just(tok: u32, cache: &mut ParserCache) -> ParserIndex {
    let p = Parser::Just(Just(tok));
    p.cache(cache)
}

impl Display for Just {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "Just({})", self.0)
    }
}
