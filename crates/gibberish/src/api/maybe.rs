use gibberish_core::{err::Expected, lang::Lang};

use crate::api::ptr::ParserCache;

use super::Parser;

#[derive(Debug, Clone, PartialEq, Hash, Eq)]
pub enum Requirement {
    Yes,
    No,
    Maybe,
}

impl<'a> Requirement {
    pub fn expected<L: Lang>(
        &self,
        parser: &Parser<L>,
        next: &Parser<L>,
        cache: &ParserCache<L>,
    ) -> Vec<Expected<L>> {
        match self {
            Requirement::Yes => parser.expected(cache),
            Requirement::No => next.expected(cache),
            Requirement::Maybe => {
                let mut res = parser.expected(cache);
                res.extend(next.expected(cache));
                res
            }
        }
    }
}
