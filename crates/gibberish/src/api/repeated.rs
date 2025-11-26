use gibberish_core::err::Expected;
use gibberish_core::lang::Lang;

use crate::api::Parser;

use crate::api::ptr::{ParserCache, ParserIndex};

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Repeated<L: Lang>(pub ParserIndex<L>);

impl<'a, L: Lang> Repeated<L> {
    pub fn expected(&self, cache: &ParserCache<L>) -> Vec<Expected<L>> {
        self.0.get_ref(cache).expected(cache)
    }
}

impl<L: Lang> ParserIndex<L> {
    pub fn repeated(self, cache: &mut ParserCache<L>) -> ParserIndex<L> {
        Parser::Repeated(Repeated(self)).cache(cache)
    }
}
