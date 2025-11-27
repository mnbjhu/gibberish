use gibberish_core::{
    err::Expected,
    lang::{CompiledLang, Lang},
};

use crate::api::ptr::{ParserCache, ParserIndex};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Skip {
    pub token: u32,
    pub inner: ParserIndex,
}

impl Skip {
    pub fn expected(&self, cache: &ParserCache) -> Vec<Expected<CompiledLang>> {
        self.inner.get_ref(cache).expected(cache)
    }
}

impl ParserIndex {
    pub fn skip(self, token: u32, cache: &mut ParserCache) -> ParserIndex {
        Parser::Skip(Skip { token, inner: self }).cache(cache)
    }
}
