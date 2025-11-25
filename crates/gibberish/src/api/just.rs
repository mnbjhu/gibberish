use std::fmt::{Display, Write};

use gibberish_tree::{err::Expected, lang::Lang};

use crate::api::ptr::{ParserCache, ParserIndex};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Just<L: Lang>(pub L::Token);

impl<L: Lang> Just<L> {
    pub fn expected(&self) -> Vec<Expected<L>> {
        vec![Expected::Token(self.0.clone())]
    }
}

pub fn just<L: Lang>(tok: L::Token, cache: &mut ParserCache<L>) -> ParserIndex<L> {
    let p = Parser::Just(Just(tok));
    p.cache(cache)
}

impl<L: Lang> Display for Just<L> {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "Just({})", self.0)
    }
}
