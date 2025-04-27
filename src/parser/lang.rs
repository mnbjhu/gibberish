use std::fmt::{Debug, Display};

use logos::Logos;

use crate::{api::Parser, parser::res::PRes};

use super::{
    node::{Lexeme, Node},
    state::ParserState,
};

pub trait Lang<'src>: Clone + PartialEq + Eq + Debug {
    type Token: Clone + PartialEq + Eq + Display + Debug + Logos<'src, Source = str>;
    type Syntax: Clone + PartialEq + Eq + Display + Debug;

    fn lex(src: &str) -> Vec<Lexeme<Self>>
    where
        Self: Sized;

    fn root() -> Self::Syntax;
}

impl<'src, L: Lang<'src>> Parser<'src, L> {
    fn lex(src: &'src str) -> Vec<Lexeme<Self>>
    where
        Self: Sized,
        <<L as Lang<'src>>::Token as logos::Logos<'src>>::Extras: std::default::Default,
    {
        let mut lexer = L::Token::lexer(src);
        let mut found = vec![];
        while let Some(next) = lexer.next() {
            match next {
                Ok(next) => {
                    let lexeme = Lexeme {
                        span: lexer.span(),
                        kind: next,
                    };
                    found.push(lexeme);
                }
                Err(e) => panic!("{e:?}"),
            }
        }
        found
    }
    pub fn parse(&self, src: &str) -> Node<L> {
        let tokens = L::lex(src);
        let mut state = ParserState::new(tokens);
        let res = state.try_parse(self, false);
        assert!(matches!(res, PRes::Ok | PRes::Eof));
        state.finish()
    }
}
