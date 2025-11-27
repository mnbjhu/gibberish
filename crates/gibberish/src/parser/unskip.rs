use gibberish_core::{err::Expected, lang::CompiledLang};

use crate::parser::ptr::{ParserCache, ParserIndex};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct UnSkip {
    token: u32,
    inner: ParserIndex,
}

impl UnSkip {
    pub fn expected(&self, cache: &ParserCache) -> Vec<Expected<CompiledLang>> {
        self.inner.get_ref(cache).expected(cache)
    }
}

impl ParserIndex {
    pub fn unskip(self, token: u32, cache: &mut ParserCache) -> ParserIndex {
        Parser::UnSkip(UnSkip { token, inner: self }).cache(cache)
    }
}
