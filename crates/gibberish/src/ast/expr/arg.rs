use gibberish_core::node::Group;
use gibberish_gibberish_parser::{Gibberish, GibberishSyntax, GibberishToken};

use crate::ast::{
    expr::{ExprAst, call::StringOrInt},
    stmt::token::rust_string,
};

#[derive(Clone, Copy)]
pub enum ArgAst<'a> {
    Expr(ExprAst<'a>),
    // Named(NamedParamAst<'a>),
}

impl<'a> From<&'a Group<Gibberish>> for ArgAst<'a> {
    fn from(value: &'a Group<Gibberish>) -> Self {
        // if value.kind == GibberishSyntax::NamedParam {
        //     ArgAst::Named(NamedParamAst(value))
        // } else {
        ArgAst::Expr(ExprAst::from(value))
        // }
    }
}

#[derive(Clone, Copy)]
pub struct NamedParamAst<'a>(pub &'a Group<Gibberish>);

impl<'a> NamedParamAst<'a> {
    pub fn name(&self) -> String {
        self.0
            .lexeme_by_kind(GibberishToken::Ident)
            .unwrap()
            .text
            .clone()
    }

    pub fn value(&self) -> Option<StringOrInt> {
        if let Some(s) = self.0.lexeme_by_kind(GibberishToken::String) {
            Some(StringOrInt::String(rust_string(&s.text)))
        } else if let Some(i) = self.0.lexeme_by_kind(GibberishToken::Int) {
            Some(StringOrInt::Int(i.text.parse().unwrap()))
        } else {
            None
        }
    }
}
