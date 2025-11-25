use gibberish_tree::{err::Expected, lang::Lang};

use crate::api::ptr::{ParserCache, ParserIndex};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Break<L: Lang> {
    inner: ParserIndex<L>,
    break_: ParserIndex<L>,
}

impl<'a, L: Lang> Break<L> {
    pub fn expected(&self, cache: &ParserCache<L>) -> Vec<Expected<L>> {
        self.inner.clone().get_ref(cache).expected(cache)
    }
}

impl<L: Lang> ParserIndex<L> {
    pub fn break_at(self, parser: ParserIndex<L>, cache: &mut ParserCache<L>) -> ParserIndex<L> {
        Parser::Break(Break {
            inner: self,
            break_: parser,
        })
        .cache(cache)
    }
}
