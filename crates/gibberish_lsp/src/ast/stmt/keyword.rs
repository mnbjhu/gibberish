use gibberish_core::node::{Group, Lexeme};
use gibberish_gibberish_parser::{Gibberish, GibberishToken};

use crate::ast::{LspItem, LspNode, expr::ExprAst, stmt::StmtAst};

#[derive(Clone, Copy)]
pub struct KeywordDefAst<'a>(pub &'a Group<Gibberish>);

impl<'a> KeywordDefAst<'a> {
    pub fn name(&self) -> Option<&'a Lexeme<Gibberish>> {
        self.0.token_by_kind(GibberishToken::Ident)
    }
}

impl<'a> LspItem<'a> for KeywordDefAst<'a> {
    fn at(&self, offset: usize) -> Option<LspNode<'a>> {
        if self.0.span().contains(&offset) {
            if let Some(name) = self.name()
                && name.span.contains(&offset)
            {
                Some(LspNode::Expr(ExprAst::Ident(name)))
            } else {
                Some(LspNode::Stmt(StmtAst::Keyword(*self)))
            }
        } else {
            None
        }
    }
}
