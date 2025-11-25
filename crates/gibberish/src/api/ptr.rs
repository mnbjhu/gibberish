use std::{collections::HashMap, marker::PhantomData};

use gibberish_tree::{lang::Lang, query::Query};

use crate::{api::Parser, dsl::lexer::RuntimeLang};

#[derive(Debug, Hash, PartialEq, Eq)]
pub struct ParserIndex<L: Lang> {
    pub index: usize,
    _pd: PhantomData<L>,
}

impl<L: Lang> Clone for ParserIndex<L> {
    fn clone(&self) -> Self {
        Self {
            index: self.index.clone(),
            _pd: self._pd.clone(),
        }
    }
}

impl<L: Lang> ParserIndex<L> {
    pub fn from(index: usize) -> ParserIndex<L> {
        ParserIndex {
            index,
            _pd: PhantomData,
        }
    }
}

pub struct ParserCache<L: Lang> {
    pub lang: L,
    pub parsers: Vec<Parser<L>>,
    pub cached: HashMap<Parser<L>, ParserIndex<L>>,
    // pub highlights: Vec<Query<RuntimeLang, TokenKind>>,
}

impl<L: Lang> ParserCache<L> {
    pub fn new(lang: L) -> Self {
        Self {
            parsers: vec![],
            cached: HashMap::new(),
            lang,
            // highlights: vec![],
        }
    }
}

impl<L: Lang> std::fmt::Debug for ParserCache<L> {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("ParserCache")
            .field("parsers", &self.parsers)
            .finish()
    }
}

impl<'a, L: Lang> ParserIndex<L> {
    pub fn get_ref(&self, cache: &'a ParserCache<L>) -> &'a Parser<L> {
        &cache.parsers[self.index]
    }

    pub fn get_mut(&self, cache: &'a mut ParserCache<L>) -> &'a mut Parser<L> {
        &mut cache.parsers[self.index]
    }
}

impl<L: Lang> Parser<L> {
    pub fn cache(self, cache: &mut ParserCache<L>) -> ParserIndex<L> {
        if let Some(cached) = cache.cached.get(&self) {
            cached.clone()
        } else {
            let index = cache.parsers.len();
            cache.parsers.push(self);
            ParserIndex::from(index)
        }
    }
}
