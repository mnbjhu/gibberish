use crate::api::ptr::{ParserCache, ParserIndex};
use gibberish_core::{
    err::Expected,
    lang::{CompiledLang, Lang},
};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Delim {
    pub start: ParserIndex,
    pub end: ParserIndex,
    pub inner: ParserIndex,
}

impl Delim {
    pub fn expected(&self, cache: &ParserCache) -> Vec<Expected<CompiledLang>> {
        self.start.get_ref(cache).expected(cache)
    }
}

impl ParserIndex {
    pub fn delim_by(
        self,
        start: ParserIndex,
        end: ParserIndex,
        cache: &mut ParserCache,
    ) -> ParserIndex {
        Parser::Delim(Delim {
            start,
            end,
            inner: self,
        })
        .cache(cache)
    }
}
