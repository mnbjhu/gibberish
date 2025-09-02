use logos::Logos;

use crate::parser::{lang::Lang, node::Lexeme};

use super::{lexer::GToken, syntax::GSyntax};

#[derive(Debug, PartialEq, Eq, Clone)]
pub struct GLang;

impl Lang for GLang {
    type Token = GToken;
    type Syntax = GSyntax;

    fn lex(src: &str) -> Vec<Lexeme<Self>>
    where
        Self: Sized,
    {
        let mut lexer = GToken::lexer(src);
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
                Err(_) => {
                    let lexeme = Lexeme {
                        span: lexer.span(),
                        kind: GToken::Error,
                    };
                    found.push(lexeme);
                }
            }
        }
        found
    }

    fn root() -> GSyntax {
        GSyntax::Root
    }
}
