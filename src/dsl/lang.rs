use logos::Logos;

use crate::parser::{lang::Lang, node::Lexeme};

use super::{lexer::PToken, syntax::PSyntax};

#[derive(Debug, PartialEq, Eq, Clone)]
pub struct PLang;

impl Lang for PLang {
    type Token = PToken;
    type Syntax = PSyntax;

    fn lex(src: &str) -> Vec<Lexeme<Self>>
    where
        Self: Sized,
    {
        let mut lexer = PToken::lexer(src);
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

    fn root() -> PSyntax {
        PSyntax::Root
    }
}
