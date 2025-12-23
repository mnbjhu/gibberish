use gibberish_core::node::{Group, Lexeme};
use gibberish_gibberish_parser::{Gibberish, GibberishToken};
use pretty::{DocAllocator, DocBuilder};

use crate::ast::{
    CheckState, LspItem, LspNode, builder::ParserBuilder, expr::ExprAst, stmt::StmtAst,
};

#[derive(Clone, Copy)]
pub struct ParserDefAst<'a>(pub &'a Group<Gibberish>);

impl<'a> ParserDefAst<'a> {
    pub fn name(&self) -> Option<&'a Lexeme<Gibberish>> {
        self.0.token_by_kind(GibberishToken::Ident)
    }

    pub fn expr(&self) -> Option<ExprAst<'a>> {
        self.0.groups().next().map(ExprAst::from)
    }

    pub fn check(&self, state: &mut CheckState<'a>) {
        if let Some(expr) = self.expr() {
            expr.check(state);
        }
    }

    pub fn build(&self, builder: &mut ParserBuilder) {
        let name = self.name().unwrap().text.as_str();
        if let Some(expr) = self.expr() {
            let mut p = expr.build(builder);
            if !name.starts_with("_") && name != "root" {
                p = p.named(name.to_string());
            }
            let index = builder.vars.iter().position(|(it, _)| it == name).unwrap();
            builder.vars[index] = (name.to_string(), p.clone());
        }
    }

    pub fn pretty<'b, D, A>(self, allocator: &'b D) -> DocBuilder<'b, D, A>
    where
        D: DocAllocator<'b, A>,
        D::Doc: Clone,
        A: Clone,
        'a: 'b,
    {
        allocator
            .text("parser ")
            .append(&self.name().unwrap().text)
            .append(" = ")
            .append(self.expr().unwrap().pretty(allocator))
            .group()
    }
}

impl<'a> LspItem<'a> for ParserDefAst<'a> {
    fn at(&self, offset: usize) -> Option<LspNode<'a>> {
        if self.0.span().contains(&offset) {
            if let Some(name) = self.name()
                && name.span.contains(&offset)
            {
                Some(LspNode::Expr(ExprAst::Ident(name)))
            } else if let Some(expr) = self.expr()
                && let Some(expr) = expr.at(offset)
            {
                Some(expr)
            } else {
                Some(LspNode::Stmt(StmtAst::Parser(*self)))
            }
        } else {
            None
        }
    }
}
