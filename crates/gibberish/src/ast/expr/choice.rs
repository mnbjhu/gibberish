use gibberish_core::node::Group;
use gibberish_gibberish_parser::Gibberish;

use crate::{
    ast::{builder::ParserBuilder, expr::ExprAst},
    parser::{
        Parser,
        choice::{Choice, choice as build_choice},
    },
};

#[derive(Clone, Copy)]
pub struct ChoiceAst<'a>(pub &'a Group<Gibberish>);

impl<'a> ChoiceAst<'a> {
    pub fn iter(&self) -> impl Iterator<Item = ExprAst<'a>> {
        self.0.groups().map(ExprAst::from)
    }

    pub fn build(&self, builder: &mut ParserBuilder) -> Parser {
        let items = self.iter().map(|it| it.build(builder)).collect::<Vec<_>>();
        build_choice(items)
    }
}
