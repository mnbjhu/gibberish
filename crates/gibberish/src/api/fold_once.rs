use gibberish_tree::{err::Expected, lang::Lang};

use crate::api::ptr::{ParserCache, ParserIndex};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct FoldOnce<L: Lang> {
    pub name: L::Syntax,
    pub first: ParserIndex<L>,
    pub next: ParserIndex<L>,
}

impl<'a, L: Lang> FoldOnce<L> {
    pub fn expected(&self, cache: &ParserCache<L>) -> Vec<Expected<L>> {
        self.first.get_ref(cache).expected(cache)
    }
}

impl<L: Lang> ParserIndex<L> {
    pub fn fold_once(
        self,
        name: L::Syntax,
        next: ParserIndex<L>,
        cache: &mut ParserCache<L>,
    ) -> ParserIndex<L> {
        Parser::FoldOnce(FoldOnce {
            name,
            first: self,
            next,
        })
        .cache(cache)
    }
}
