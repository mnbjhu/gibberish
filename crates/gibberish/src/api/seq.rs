use gibberish_core::{err::Expected, lang::Lang};

use crate::api::ptr::{ParserCache, ParserIndex};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Seq<L: Lang>(pub Vec<ParserIndex<L>>);

impl<'a, L: Lang> Seq<L> {
    pub fn expected(&self, cache: &ParserCache<L>) -> Vec<Expected<L>> {
        self.0
            .first()
            .expect("Seq should have at least one element")
            .get_ref(cache)
            .expected(cache)
    }
}

pub fn seq<L: Lang>(parts: Vec<ParserIndex<L>>, cache: &mut ParserCache<L>) -> ParserIndex<L> {
    Parser::Seq(Seq(parts)).cache(cache)
}

impl<L: Lang> ParserIndex<L> {
    pub fn then(self, other: ParserIndex<L>, cache: &mut ParserCache<L>) -> ParserIndex<L> {
        if let Parser::Seq(seq) = self.get_mut(cache) {
            seq.0.push(other);
            self
        } else {
            seq(vec![self, other], cache)
        }
    }
}
