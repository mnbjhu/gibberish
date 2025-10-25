use crate::{
    dsl::{
        ast::expr::ExprAst,
        lst::{lang::DslLang, syntax::DslSyntax as S, token::DslToken as T},
    },
    parser::node::{Group, Lexeme},
};

#[derive(Clone, Copy)]
pub struct ParserDefAst<'a>(pub &'a Group<DslLang>);

impl<'a> ParserDefAst<'a> {
    pub fn name(&self) -> &'a Lexeme<DslLang> {
        self.0.lexeme_by_kind(T::Ident).unwrap()
    }

    pub fn expr(&self) -> Option<ExprAst<'a>> {
        self.0
            .green_node_by_name(S::Expr)
            .map(|it| it.green_children().next().unwrap().into())
    }
}
