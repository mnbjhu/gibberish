use gibberish_tree::{err::Expected, lang::Lang};

use crate::api::ptr::{ParserCache, ParserIndex};

use super::{Parser, maybe::Requirement};

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Sep<L: Lang> {
    pub sep: ParserIndex<L>,
    pub item: ParserIndex<L>,
    pub leading: Requirement,
    pub trailing: Requirement,
    pub at_least: usize,
}

impl<'a, L: Lang> Sep<L> {
    pub fn expected(&self, cache: &ParserCache<L>) -> Vec<Expected<L>> {
        self.leading
            .expected(self.sep.get_ref(cache), self.item.get_ref(cache), cache)
    }
}

impl<L: Lang> ParserIndex<L> {
    pub fn sep_by(self, sep: ParserIndex<L>, cache: &mut ParserCache<L>) -> ParserIndex<L> {
        Parser::Sep(Sep {
            item: self,
            sep,
            leading: Requirement::No,
            trailing: Requirement::No,
            at_least: 0,
        })
        .cache(cache)
    }

    pub fn sep_by_extra(
        self,
        sep: ParserIndex<L>,
        leading: Requirement,
        trailing: Requirement,
        cache: &mut ParserCache<L>,
    ) -> ParserIndex<L> {
        Parser::Sep(Sep {
            item: self,
            sep,
            leading,
            trailing,
            at_least: 0,
        })
        .cache(cache)
    }
}
