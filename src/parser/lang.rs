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

    fn parser() -> Parser<Self>;

    fn parse(src: &str) -> Node<Self> {
        let tokens = Self::lex(src);
        let mut state = ParserState::new(tokens);
        let res = Self::parser().parse(&mut state);
        assert_eq!(res, PRes::Ok);
        state.finish()
    }
}
