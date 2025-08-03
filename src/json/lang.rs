use logos::Logos;
use rowan::{Language, SyntaxKind};

use crate::parser::{lang::Lang, node::Lexeme};

use super::{lexer::JsonToken, syntax::JsonSyntax};

#[derive(Debug, PartialEq, Eq, Clone, Hash, PartialOrd, Ord, Copy)]
pub struct JsonLang;

impl Lang for JsonLang {
    fn lex(src: &str) -> Vec<Lexeme<Self>>
    where
        Self: Sized,
    {
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
}

impl Language for JsonLang {
    type Kind = JsonToken;

    fn kind_from_raw(raw: rowan::SyntaxKind) -> Self::Kind {
        unsafe { std::mem::transmute(raw.0) }
    }

    fn kind_to_raw(kind: Self::Kind) -> rowan::SyntaxKind {
        kind.into()
    }
}

impl From<JsonToken> for SyntaxKind {
    fn from(value: JsonToken) -> Self {
        SyntaxKind(value as u16)
    }
}
