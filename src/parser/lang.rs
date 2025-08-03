use std::fmt::Debug;

use rowan::{GreenNode, Language};

use crate::{api::Parser, parser::res::PRes};

use super::{node::Lexeme, state::ParserState};

pub trait Lang: Clone + PartialEq + Eq + Debug + Language {
    fn lex(src: &str) -> Vec<Lexeme<Self>>
    where
        Self: Sized;
}

impl<L: Lang> Parser<L> {
    pub fn parse(&self, src: &str) -> GreenNode {
        let tokens = L::lex(src);
        let mut state = ParserState::new(tokens);
        let res = state.try_parse(self, false);
        assert!(matches!(res, PRes::Ok | PRes::Eof));
        state.finish()
    }
}
