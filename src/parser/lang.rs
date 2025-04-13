use std::fmt::Display;

use crate::{dsl::Parser, parser::res::PRes};

use super::{
    node::{Lexeme, Node},
    state::ParserState,
};

pub trait Lang: Clone + PartialEq + Eq {
    type Token: Clone + PartialEq + Eq + Display;
    type Syntax: Clone + PartialEq + Eq + Display;

    fn lex(src: &str) -> Vec<Lexeme<Self>>
    where
        Self: Sized;

    fn root() -> Self::Syntax;
}

impl<L: Lang> Parser<L> {
    pub fn parse(&self, src: &str) -> Node<L> {
        let tokens = L::lex(src);
        let mut state = ParserState::new(tokens);
        let res = self.do_parse(&mut state);
        assert_eq!(res, PRes::Ok);
        state.finish()
    }
}
