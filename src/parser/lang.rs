use std::fmt::{Debug, Display};
use std::hash::Hash;

use crate::api::ptr::ParserCache;
use crate::{api::Parser, parser::res::PRes};

use super::{
    node::{Lexeme, Node},
    state::ParserState,
};

pub trait Lang: Clone + PartialEq + Eq + Debug + Copy + Hash {
    type Token: Clone + PartialEq + Eq + Display + Debug + Hash;
    type Syntax: Clone + PartialEq + Eq + Display + Debug + Hash;

    fn lex(src: &str) -> Vec<Lexeme<Self>>
    where
        Self: Sized;

    fn root() -> Self::Syntax;
}

impl<L: Lang> Parser<L> {
    pub fn parse(&self, src: &str, cache: &ParserCache<L>) -> Node<L> {
        let tokens = L::lex(src);
        let mut state = ParserState::new(tokens, cache);
        let (res, _) = state.try_parse(self, true);
        assert!(matches!(res, PRes::Ok | PRes::Eof));
        state.finish()
    }
}
