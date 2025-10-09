use std::fmt::Display;

use logos::Logos;

use crate::parser::{lang::Lang, node::Lexeme};

use super::{lexer::JsonToken, syntax::JsonSyntax};

#[derive(Debug, PartialEq, Eq, Clone, Copy, Hash)]
pub struct JsonLang;

impl Lang for JsonLang {
    type Token = JsonToken;
    type Syntax = JsonSyntax;

    fn lex(&self, src: &str) -> Vec<Lexeme<Self>> {
        let mut lexer = JsonToken::lexer(src);
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
                Err(e) => panic!("{e:?}"),
            }
        }
        found
    }

    fn root(&self) -> JsonSyntax {
        JsonSyntax::Root
    }
}

impl Display for JsonLang {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "JsonLang")
    }
}
