use gibberish_tree::{err::Expected, lang::Lang};

use crate::api::ptr::{ParserCache, ParserIndex};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Choice<L: Lang> {
    pub options: Vec<ParserIndex<L>>,
}

impl<'a, L: Lang> Choice<L> {
    pub fn expected(&self, cache: &ParserCache<L>) -> Vec<Expected<L>> {
        self.options
            .iter()
            .flat_map(|it| it.get_ref(cache).expected(cache))
            .collect()
    }
}

pub fn choice<L: Lang>(options: Vec<ParserIndex<L>>, cache: &mut ParserCache<L>) -> ParserIndex<L> {
    Parser::Choice(Choice { options }).cache(cache)
}

impl<L: Lang> ParserIndex<L> {
    pub fn or(self, other: ParserIndex<L>, cache: &mut ParserCache<L>) -> ParserIndex<L> {
        if let Parser::Choice(options) = self.get_mut(cache) {
            options.options.push(other);
            self
        } else {
            choice(vec![self, other], cache)
        }
    }
}
