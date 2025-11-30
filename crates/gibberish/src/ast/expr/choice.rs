use std::collections::HashMap;

use gibberish_core::node::Group;
use gibberish_gibberish_parser::Gibberish;

use crate::{
    ast::{builder::ParserBuilder, expr::ExprAst},
    parser::{choice::choice, ptr::ParserIndex},
};

#[derive(Clone, Copy)]
pub struct ChoiceAst<'a>(pub &'a Group<Gibberish>);

impl<'a> ChoiceAst<'a> {
    pub fn iter(&self) -> impl Iterator<Item = ExprAst<'a>> {
        self.0.green_children().map(ExprAst::from)
    }

    pub fn build(&self, builder: &mut ParserBuilder) -> ParserIndex {
        let items = self.iter().map(|it| it.build(builder)).collect::<Vec<_>>();
        let mut intersects = HashMap::<(usize, usize), Vec<u32>>::new();
        for (x, x_parser) in items.iter().enumerate() {
            let x_items = x_parser
                .get_ref(&builder.cache)
                .start_tokens(&builder.cache);
            let next_index = x + 1;
            for (y, y_parser) in items[next_index..].iter().enumerate() {
                let y_items = y_parser
                    .get_ref(&builder.cache)
                    .start_tokens(&builder.cache);
                let union = x_items.intersection(&y_items).copied().collect::<Vec<_>>();
                if !union.is_empty() {
                    intersects.insert((x, y), union);
                }
            }
        }
        if !intersects.is_empty() {
            builder.error("Options start with the same tokens", self.0.span());
        }
        choice(items, &mut builder.cache)
    }
}
