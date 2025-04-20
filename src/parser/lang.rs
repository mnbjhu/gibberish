use std::fmt::{Debug, Display};

use crate::{api::Parser, parser::res::PRes};

use super::{
    node::{Lexeme, Node},
    state::ParserState,
};

pub trait Lang: Clone + PartialEq + Eq + Debug {
    type Token: Clone + PartialEq + Eq + Display + Debug;
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
        let mut res = self.do_parse(&mut state, false);
        while !matches!(res, PRes::Ok | PRes::Eof) {
            res = self.do_parse(&mut state, false);
            state.bump_err(self.expected());
        }
        state.finish()
    }
}
