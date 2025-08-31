use std::fmt::{Debug, Display};
use std::hash::Hash;

use crate::{api::Parser, parser::res::PRes};

use super::{
    node::{Lexeme, Node},
    state::ParserState,
};

pub trait Lang: Clone + PartialEq + Eq + Debug {
    type Token: Clone + PartialEq + Eq + Display + Debug + Hash;
    type Syntax: Clone + PartialEq + Eq + Display + Debug;

    fn lex(src: &str) -> Vec<Lexeme<Self>>
    where
        Self: Sized;

    fn root() -> Self::Syntax;
}

impl<L: Lang> Parser<L> {
    pub fn parse(&self, src: &str) -> Node<L> {
        let tokens = L::lex(src);
        let mut state = ParserState::new(tokens);
        let (res, _) = state.try_parse(self, true);
        assert!(matches!(res, PRes::Ok | PRes::Eof));
        state.finish()
    }
}
