use gibberish_core::node::{Group, Lexeme};
use gibberish_gibberish_parser::{Gibberish, GibberishToken};

use crate::ast::{CheckState, LspItem, LspNode, expr::ExprAst, stmt::StmtAst};

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
