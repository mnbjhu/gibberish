use gibberish_core::{
    err::Expected,
    lang::{CompiledLang, Lang},
};

use crate::api::ptr::{ParserCache, ParserIndex};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Choice {
    pub options: Vec<ParserIndex>,
}

impl Choice {
    pub fn expected(&self, cache: &ParserCache) -> Vec<Expected<CompiledLang>> {
        self.options
            .iter()
            .flat_map(|it| it.get_ref(cache).expected(cache))
            .collect()
    }
}

pub fn choice(options: Vec<ParserIndex>, cache: &mut ParserCache) -> ParserIndex {
    Parser::Choice(Choice { options }).cache(cache)
}
