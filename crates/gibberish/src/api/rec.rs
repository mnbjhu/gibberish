use gibberish_core::{err::Expected, lang::Lang};

use crate::api::ptr::{ParserCache, ParserIndex};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Recursive<L: Lang>(pub ParserIndex<L>);

impl<'a, L: Lang> Recursive<L> {
    pub fn expected(&self, cache: &ParserCache<L>) -> Vec<Expected<L>> {
        self.0.get_ref(cache).expected(cache)
    }
}

pub fn recursive<L: Lang>(
    mut builder: impl FnMut(ParserIndex<L>, &mut ParserCache<L>) -> ParserIndex<L>,
    cache: &mut ParserCache<L>,
) -> ParserIndex<L> {
    let index = ParserIndex::from(cache.parsers.len());
    cache
        .parsers
        .push(Parser::Rec(Recursive(ParserIndex::from(0))));
    let res = builder(index.clone(), cache);
    let Some(Parser::Rec(p)) = cache.parsers.get_mut(index.index) else {
        panic!()
    };
    p.0.index = res.index;
    index
}
