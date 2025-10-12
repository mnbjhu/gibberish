use crate::{
    dsl::lst::{lang::DslLang, token::DslToken as T},
    parser::node::{Group, Lexeme},
};

#[derive(Clone, Copy)]
pub struct TokenDefAst<'a>(pub &'a Group<DslLang>);

impl<'a> TokenDefAst<'a> {
    pub fn name(&self) -> &'a Lexeme<DslLang> {
        self.0.lexeme_by_kind(T::Ident).unwrap()
    }

    pub fn value(&self) -> Option<&'a Lexeme<DslLang>> {
        self.0.lexeme_by_kind(T::String)
    }
}
