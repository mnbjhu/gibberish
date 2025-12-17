use gibberish_core::node::{Group, Lexeme};
use gibberish_gibberish_parser::{Gibberish, GibberishToken};

use crate::ast::{LspItem, LspNode, expr::ExprAst, stmt::StmtAst};

#[derive(Clone, Copy)]
pub struct TokenDefAst<'a>(pub &'a Group<Gibberish>);

impl<'a> TokenDefAst<'a> {
    pub fn name(&self) -> Option<&'a Lexeme<Gibberish>> {
        self.0.token_by_kind(GibberishToken::Ident)
    }

    pub fn value(&self) -> Option<&'a Lexeme<Gibberish>> {
        self.0.token_by_kind(GibberishToken::String)
    }
}

impl<'a> LspItem<'a> for TokenDefAst<'a> {
    fn at(&self, offset: usize) -> Option<LspNode<'a>> {
        if self.0.span().contains(&offset) {
            if let Some(name) = self.name()
                && name.span.contains(&offset)
            {
                Some(LspNode::Expr(ExprAst::Ident(name)))
            } else {
                Some(LspNode::Stmt(StmtAst::Token(*self)))
            }
        } else {
            None
        }
    }
}
