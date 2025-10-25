use crate::{
    dsl::{
        ast::expr::ExprAst,
        lst::{lang::DslLang, syntax::DslSyntax as S, token::DslToken as T},
    },
    parser::node::{Group, Lexeme},
};

#[derive(Clone, Copy)]
pub struct FoldDefAst<'a>(pub &'a Group<DslLang>);

impl<'a> FoldDefAst<'a> {
    pub fn name(&self) -> &'a Lexeme<DslLang> {
        self.0.lexeme_by_kind(T::Ident).unwrap()
    }

    fn fold(&self) -> &'a Group<DslLang> {
        let res = self
            .0
            .green_node_by_name(S::Expr)
            .unwrap()
            .green_node_by_name(S::Fold)
            .unwrap();
        assert_eq!(res.kind, S::Fold);
        res
    }

    pub fn first(&self) -> ExprAst<'a> {
        self.fold().green_children().next().unwrap().into()
    }

    pub fn next(&self) -> Option<ExprAst<'a>> {
        let mut iter = self.fold().green_children();
        iter.next().unwrap();
        iter.next().map(|it| it.into())
    }
}
