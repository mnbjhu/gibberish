use gibberish_core::{
    err::Expected,
    lang::{CompiledLang, Lang},
};

use crate::api::ptr::{ParserCache, ParserIndex};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Seq(pub Vec<ParserIndex>);

impl<'a> Seq {
    pub fn expected(&self, cache: &ParserCache) -> Vec<Expected<CompiledLang>> {
        self.0
            .first()
            .expect("Seq should have at least one element")
            .get_ref(cache)
            .expected(cache)
    }
}

pub fn seq(parts: Vec<ParserIndex>, cache: &mut ParserCache) -> ParserIndex {
    Parser::Seq(Seq(parts)).cache(cache)
}

impl ParserIndex {
    pub fn then(self, other: ParserIndex, cache: &mut ParserCache) -> ParserIndex {
        if let Parser::Seq(seq) = self.get_mut(cache) {
            seq.0.push(other);
            self
        } else {
            seq(vec![self, other], cache)
        }
    }
}
