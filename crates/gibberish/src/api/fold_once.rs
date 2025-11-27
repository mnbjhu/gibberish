use gibberish_core::{
    err::Expected,
    lang::{CompiledLang, Lang},
};

use crate::api::ptr::{ParserCache, ParserIndex};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct FoldOnce {
    pub name: u32,
    pub first: ParserIndex,
    pub next: ParserIndex,
}

impl<'a> FoldOnce {
    pub fn expected(&self, cache: &ParserCache) -> Vec<Expected<CompiledLang>> {
        self.first.get_ref(cache).expected(cache)
    }
}

impl ParserIndex {
    pub fn fold_once(self, name: u32, next: ParserIndex, cache: &mut ParserCache) -> ParserIndex {
        Parser::FoldOnce(FoldOnce {
            name,
            first: self,
            next,
        })
        .cache(cache)
    }
}
