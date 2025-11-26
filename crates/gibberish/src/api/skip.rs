use gibberish_core::{err::Expected, lang::Lang};

use crate::api::ptr::{ParserCache, ParserIndex};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Skip<L: Lang> {
    pub token: L::Token,
    pub inner: ParserIndex<L>,
}

impl<'a, L: Lang> Skip<L> {
    pub fn expected(&self, cache: &ParserCache<L>) -> Vec<Expected<L>> {
        self.inner.get_ref(cache).expected(cache)
    }
}

impl<L: Lang> ParserIndex<L> {
    pub fn skip(self, token: L::Token, cache: &mut ParserCache<L>) -> ParserIndex<L> {
        Parser::Skip(Skip { token, inner: self }).cache(cache)
    }
}
