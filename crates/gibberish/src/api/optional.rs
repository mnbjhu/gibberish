use gibberish_core::{err::Expected, lang::CompiledLang};

use crate::api::{
    Parser,
    ptr::{ParserCache, ParserIndex},
};

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Optional(pub ParserIndex);

impl Optional {
    pub fn expected(&self, cache: &ParserCache) -> Vec<Expected<CompiledLang>> {
        self.0.get_ref(cache).expected(cache)
    }
}

impl ParserIndex {
    pub fn or_not(self, cache: &mut ParserCache) -> ParserIndex {
        Parser::Optional(Optional(self)).cache(cache)
    }
}
