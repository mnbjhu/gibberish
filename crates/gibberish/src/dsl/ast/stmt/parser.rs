use gibberish_core::node::{Group, Lexeme};
use gibberish_gibberish_parser::{Gibberish, GibberishToken};

use crate::dsl::ast::expr::ExprAst;

#[derive(Clone, Copy)]
pub struct ParserDefAst<'a>(pub &'a Group<Gibberish>);

impl<'a> ParserDefAst<'a> {
    pub fn name(&self) -> &'a Lexeme<Gibberish> {
        self.0.lexeme_by_kind(GibberishToken::Ident).unwrap()
    }

    pub fn expr(&self) -> Option<ExprAst<'a>> {
        self.0.green_children().next().map(ExprAst::from)
    }
}
