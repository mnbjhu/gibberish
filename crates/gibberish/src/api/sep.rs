use gibberish_core::{
    err::Expected,
    lang::{CompiledLang, Lang},
};

use crate::api::ptr::{ParserCache, ParserIndex};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Sep {
    pub sep: ParserIndex,
    pub item: ParserIndex,
    pub at_least: usize,
}

impl Sep {
    pub fn expected(&self, cache: &ParserCache) -> Vec<Expected<CompiledLang>> {
        self.sep.get_ref(cache).expected(cache)
    }
}

impl ParserIndex {
    pub fn sep_by(self, sep: ParserIndex, cache: &mut ParserCache) -> ParserIndex {
        Parser::Sep(Sep {
            item: self,
            sep,
            at_least: 0,
        })
        .cache(cache)
    }

    pub fn sep_by_extra(self, sep: ParserIndex, cache: &mut ParserCache) -> ParserIndex {
        Parser::Sep(Sep {
            item: self,
            sep,
            at_least: 0,
        })
        .cache(cache)
    }
}
