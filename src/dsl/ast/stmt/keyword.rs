use crate::{
    dsl::lst::{lang::DslLang, token::DslToken as T},
    parser::node::{Group, Lexeme},
};
#[derive(Clone, Copy)]
pub struct KeywordDefAst<'a>(pub &'a Group<DslLang>);

impl<'a> KeywordDefAst<'a> {
    pub fn name(&self) -> &'a Lexeme<DslLang> {
        self.0.lexeme_by_kind(T::Ident).unwrap()
    }
}
