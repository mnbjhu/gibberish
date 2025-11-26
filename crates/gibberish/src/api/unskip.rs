use gibberish_core::{err::Expected, lang::Lang};

use crate::api::ptr::{ParserCache, ParserIndex};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct UnSkip<L: Lang> {
    token: L::Token,
    inner: ParserIndex<L>,
}

impl<'a, L: Lang> UnSkip<L> {
    pub fn expected(&self, cache: &ParserCache<L>) -> Vec<Expected<L>> {
        self.inner.get_ref(cache).expected(cache)
    }
}

impl<L: Lang> ParserIndex<L> {
    pub fn unskip(self, token: L::Token, cache: &mut ParserCache<L>) -> ParserIndex<L> {
        Parser::UnSkip(UnSkip { token, inner: self }).cache(cache)
    }
}
