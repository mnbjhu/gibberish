use gibberish_core::{err::Expected, lang::Lang};

use crate::api::{
    Parser,
    ptr::{ParserCache, ParserIndex},
};

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Optional<L: Lang>(pub ParserIndex<L>);

impl<'a, L: Lang> Optional<L> {
    pub fn expected(&self, cache: &ParserCache<L>) -> Vec<Expected<L>> {
        self.0.get_ref(cache).expected(cache)
    }
}

impl<L: Lang> ParserIndex<L> {
    pub fn or_not(self, cache: &mut ParserCache<L>) -> ParserIndex<L> {
        Parser::Optional(Optional(self)).cache(cache)
    }
}
