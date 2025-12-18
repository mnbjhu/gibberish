use gibberish_core::node::Group;
use gibberish_gibberish_parser::Gibberish;

use crate::{
    ast::{builder::ParserBuilder, expr::ExprAst},
    parser::{Parser, seq::seq},
};

#[derive(Clone, Copy)]
pub struct SeqAst<'a>(pub &'a Group<Gibberish>);

impl<'a> SeqAst<'a> {
    pub fn iter(&self) -> impl Iterator<Item = ExprAst<'a>> {
        self.0.groups().map(ExprAst::from)
    }

    pub fn build(&self, builder: &mut ParserBuilder) -> Parser {
        let items = self.iter().map(|it| it.build(builder)).collect::<Vec<_>>();
        seq(items)
    }
}
