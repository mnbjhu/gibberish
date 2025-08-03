use std::mem;

use logos::Logos;
use rowan::{Language, SyntaxKind};

use crate::parser::{lang::Lang, node::Lexeme};

use super::lexer::PToken;

#[derive(Debug, PartialEq, Eq, Clone, Hash, PartialOrd, Ord, Copy)]
pub struct PLang;

impl Lang for PLang {
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
                        text: lexer.slice().to_string(),
                    };
                    found.push(lexeme);
                }
                Err(_) => {
                    let lexeme = Lexeme {
                        span: lexer.span(),
                        kind: PToken::Error,
                        text: lexer.slice().to_string(),
                    };
                    found.push(lexeme);
                }
            }
        }
        found
    }
}

impl Language for PLang {
    type Kind = PToken;

    fn kind_from_raw(raw: SyntaxKind) -> Self::Kind {
        // SAFETY: raw.0 was produced by our From<SyntaxKind>
        unsafe { mem::transmute(raw.0) }
    }

    fn kind_to_raw(kind: Self::Kind) -> SyntaxKind {
        kind.into()
    }
}
