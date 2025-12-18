use gibberish_core::node::{Group, Lexeme};
use gibberish_gibberish_parser::Gibberish;

use crate::ast::CheckState;
use crate::ast::LspItem;
use crate::ast::LspNode;
use crate::ast::builder::ParserBuilder;
use crate::ast::expr::ExprAst;
use crate::ast::stmt::StmtAst;

use gibberish_gibberish_parser::GibberishSyntax as S;
use gibberish_gibberish_parser::GibberishToken as T;

#[derive(Clone, Copy)]
pub struct FoldDefAst<'a>(pub &'a Group<Gibberish>);

impl<'a> FoldDefAst<'a> {
    pub fn name(&self) -> Option<&'a Lexeme<Gibberish>> {
        self.0.token_by_kind(T::Ident)
    }

    fn fold(&self) -> &'a Group<Gibberish> {
        let res = self.0.group_by_kind(S::FoldStmt).unwrap();
        assert_eq!(res.kind, S::FoldStmt);
        res
    }

    pub fn first(&self) -> ExprAst<'a> {
        self.fold().groups().next().unwrap().into()
    }

    pub fn next(&self) -> Option<ExprAst<'a>> {
        let mut iter = self.fold().groups();
        iter.next().unwrap();
        iter.next().map(|it| it.into())
    }

    pub fn check(&self, state: &mut CheckState<'a>) {
        self.first().check(state);
        if let Some(next) = self.next() {
            next.check(state)
        }
    }

    pub fn build(&self, builder: &mut ParserBuilder) {
        let name = self.name().unwrap().text.as_str();
        assert!(!name.starts_with("_"), "Fold expressions should be named");
        let first = self.first().build(builder);
        let next = self.next().unwrap().build(builder);
        let p = first.fold_once(name.to_string(), next);
        let index = builder.vars.iter().position(|(it, _)| it == name).unwrap();
        builder.vars[index] = (name.to_string(), p.clone());
    }
}

impl<'a> LspItem<'a> for FoldDefAst<'a> {
    fn at(&self, offset: usize) -> Option<LspNode<'a>> {
        if self.0.span().contains(&offset) {
            if let Some(name) = self.name()
                && name.span.contains(&offset)
            {
                Some(LspNode::Expr(ExprAst::Ident(name)))
            } else if let Some(first) = self.first().at(offset) {
                Some(first)
            } else if let Some(next) = self.next()
                && let Some(next) = next.at(offset)
            {
                Some(next)
            } else {
                Some(LspNode::Stmt(StmtAst::Fold(*self)))
            }
        } else {
            None
        }
    }
}
