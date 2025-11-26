use std::fmt::Display;

use crate::{dsl::lexer::RuntimeLang, parser::lang::Lang};

#[derive(Debug, Clone, Copy, Hash, PartialEq, PartialOrd, Ord, Eq)]
pub struct CompileTimeLang;

impl Display for CompileTimeLang {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "CompileTimeLang")
    }
}

impl Lang for CompileTimeLang {
    type Token = u32;

    type Syntax = u32;

    fn lex(&self, _: &str) -> Vec<crate::parser::node::Lexeme<Self>>
    where
        Self: Sized,
    {
        panic!("Shouldn't be called from comptime lang")
    }

    fn root(&self) -> Self::Syntax {
        panic!("Shouldn't be called from comptime lang")
    }

    fn token_name(&self, token: &Self::Token) -> String {
        panic!("Shouldn't be called from comptime lang")
    }

    fn syntax_name(&self, syntax: &Self::Syntax) -> String {
        panic!("Shouldn't be called from comptime lang")
    }
}
