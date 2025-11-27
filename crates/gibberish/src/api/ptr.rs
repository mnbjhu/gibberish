use std::collections::HashMap;


use crate::api::Parser;

#[derive(Debug, Hash, PartialEq, Eq)]
pub struct ParserIndex {
    pub index: usize,
}

impl Clone for ParserIndex {
    fn clone(&self) -> Self {
        Self { index: self.index }
    }
}

impl ParserIndex {
    pub fn from(index: usize) -> ParserIndex {
        ParserIndex { index }
    }
}

pub struct ParserCache {
    pub parsers: Vec<Parser>,
    pub cached: HashMap<Parser, ParserIndex>,
}

impl ParserCache {
    pub fn new() -> Self {
        Self {
            parsers: vec![],
            cached: HashMap::new(),
            // highlights: vec![],
        }
    }
}

impl std::fmt::Debug for ParserCache {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("ParserCache")
            .field("parsers", &self.parsers)
            .finish()
    }
}

impl<'a> ParserIndex {
    pub fn get_ref(&self, cache: &'a ParserCache) -> &'a Parser {
        &cache.parsers[self.index]
    }

    pub fn get_mut(&self, cache: &'a mut ParserCache) -> &'a mut Parser {
        &mut cache.parsers[self.index]
    }
}

impl Parser {
    pub fn cache(self, cache: &mut ParserCache) -> ParserIndex {
        if let Some(cached) = cache.cached.get(&self) {
            cached.clone()
        } else {
            let index = cache.parsers.len();
            cache.parsers.push(self);
            ParserIndex::from(index)
        }
    }
}
