use gibberish_core::node::Group;
use gibberish_gibberish_parser::Gibberish;

use crate::{
    api::{ptr::ParserIndex, seq::seq},
    dsl::{ast::expr::ExprAst, parser::ParserBuilder},
};

#[derive(Clone, Copy)]
pub struct SeqAst<'a>(pub &'a Group<Gibberish>);

impl<'a> SeqAst<'a> {
    pub fn iter(&self) -> impl Iterator<Item = ExprAst<'a>> {
        self.0.green_children().map(ExprAst::from)
    }
    pub fn build(&self, builder: &mut ParserBuilder) -> ParserIndex {
        let items = self.iter().map(|it| it.build(builder)).collect::<Vec<_>>();
        seq(items, &mut builder.cache)
    }
}
