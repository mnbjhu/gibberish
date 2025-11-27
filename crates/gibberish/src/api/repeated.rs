use gibberish_core::err::Expected;
use gibberish_core::lang::{CompiledLang, Lang};

use crate::api::Parser;

use crate::api::ptr::{ParserCache, ParserIndex};

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Repeated(pub ParserIndex);

impl<'a> Repeated {
    pub fn expected(&self, cache: &ParserCache) -> Vec<Expected<CompiledLang>> {
        self.0.get_ref(cache).expected(cache)
    }
}

impl ParserIndex {
    pub fn repeated(self, cache: &mut ParserCache) -> ParserIndex {
        Parser::Repeated(Repeated(self)).cache(cache)
    }
}
