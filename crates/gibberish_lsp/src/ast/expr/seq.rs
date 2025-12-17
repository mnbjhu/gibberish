use gibberish_core::node::Group;
use gibberish_gibberish_parser::Gibberish;

use crate::ast::expr::ExprAst;

#[derive(Clone, Copy)]
pub struct SeqAst<'a>(pub &'a Group<Gibberish>);

impl<'a> SeqAst<'a> {
    pub fn iter(&self) -> impl Iterator<Item = ExprAst<'a>> {
        self.0.groups().map(ExprAst::from)
    }
}
