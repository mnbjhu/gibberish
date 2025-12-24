use gibberish_core::node::Group;
use gibberish_gibberish_parser::Gibberish;
use pretty::{DocAllocator, DocBuilder};

use crate::{
    ast::{builder::ParserBuilder, expr::ExprAst},
    parser::Parser,
};

pub const INDENT: isize = 4;

#[derive(Clone, Copy)]
pub struct ChoiceAst<'a>(pub &'a Group<Gibberish>);

impl<'a> ChoiceAst<'a> {
    pub fn iter(&self) -> impl Iterator<Item = ExprAst<'a>> {
        self.0.groups().map(ExprAst::from)
    }

    pub fn build(&self, builder: &mut ParserBuilder) -> Parser {
        let items = self.iter().map(|it| it.build(builder)).collect::<Vec<_>>();
        crate::parser::choice::choice(items)
    }

    pub fn pretty<'b, D, A>(self, allocator: &'b D) -> DocBuilder<'b, D, A>
    where
        D: DocAllocator<'b, A>,
        D::Doc: Clone,
        A: Clone,
        'a: 'b,
    {
        allocator
            .intersperse(
                self.0
                    .groups()
                    .map(ExprAst::from)
                    .map(|it| it.pretty(allocator)),
                allocator.line().append(allocator.text("| ")),
            )
            .group()
    }
}
