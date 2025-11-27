use gibberish_core::node::Group;
use gibberish_gibberish_parser::Gibberish;

use crate::{
    api::{choice::choice, ptr::ParserIndex},
    dsl::ast::{builder::ParserBuilder, expr::ExprAst},
};

#[derive(Clone, Copy)]
pub struct ChoiceAst<'a>(pub &'a Group<Gibberish>);

impl<'a> ChoiceAst<'a> {
    pub fn iter(&self) -> impl Iterator<Item = ExprAst<'a>> {
        self.0.green_children().map(ExprAst::from)
    }

    pub fn build(&self, builder: &mut ParserBuilder) -> ParserIndex {
        let items = self.iter().map(|it| it.build(builder)).collect::<Vec<_>>();
        choice(items, &mut builder.cache)
    }
}
