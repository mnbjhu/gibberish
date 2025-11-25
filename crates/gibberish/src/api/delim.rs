use gibberish_tree::{err::Expected, lang::Lang};
use tracing::warn;

use crate::api::ptr::{ParserCache, ParserIndex};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Delim<L: Lang> {
    pub start: ParserIndex<L>,
    pub end: ParserIndex<L>,
    pub inner: ParserIndex<L>,
}

impl<'a, L: Lang> Delim<L> {
    pub fn expected(&self, cache: &ParserCache<L>) -> Vec<Expected<L>> {
        self.start.get_ref(cache).expected(cache)
    }
}

impl<L: Lang> ParserIndex<L> {
    pub fn delim_by(
        self,
        start: ParserIndex<L>,
        end: ParserIndex<L>,
        cache: &mut ParserCache<L>,
    ) -> ParserIndex<L> {
        Parser::Delim(Delim {
            start,
            end,
            inner: self,
        })
        .cache(cache)
    }
}
