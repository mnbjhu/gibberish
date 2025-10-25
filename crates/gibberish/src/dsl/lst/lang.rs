use std::fmt::Display;

use logos::Logos as _;

use crate::{
    dsl::lst::{syntax::DslSyntax, token::DslToken},
    parser::{lang::Lang, node::Lexeme},
};

#[derive(Debug, PartialEq, Eq, Clone, Copy, Hash)]
pub struct DslLang;

impl Lang for DslLang {
    type Token = DslToken;
    type Syntax = DslSyntax;

    fn lex(&self, src: &str) -> Vec<Lexeme<Self>> {
        let mut lexer = DslToken::lexer(src);
        let mut found = vec![];
        while let Some(next) = lexer.next() {
            match next {
                Ok(next) => {
                    let lexeme = Lexeme {
                        span: lexer.span(),
                        kind: next,
                        text: lexer.slice().to_string(),
                    };
                    found.push(lexeme);
                }
                Err(_) => {
                    let lexeme = Lexeme {
                        span: lexer.span(),
                        kind: DslToken::Err,
                        text: lexer.slice().to_string(),
                    };
                    found.push(lexeme);
                }
            }
        }
        found
    }

    fn root(&self) -> DslSyntax {
        DslSyntax::Root
    }
}
impl Display for DslLang {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "DslLang")
    }
}
