use std::collections::{HashMap, HashSet};

use gibberish_core::node::Group;
use gibberish_gibberish_parser::Gibberish;

use crate::{
    ast::{builder::ParserBuilder, expr::ExprAst},
    parser::{Parser, choice::choice, just::just, ptr::ParserIndex, rename::Rename, seq::seq},
};

#[derive(Clone, Copy)]
pub struct ChoiceAst<'a>(pub &'a Group<Gibberish>);

impl<'a> ChoiceAst<'a> {
    pub fn iter(&self) -> impl Iterator<Item = ExprAst<'a>> {
        self.0.green_children().map(ExprAst::from)
    }

    pub fn build(&self, builder: &mut ParserBuilder) -> ParserIndex {
        let items = self.iter().map(|it| it.build(builder)).collect::<Vec<_>>();
        let mut intersects = HashMap::<u32, HashSet<usize>>::new();
        for (x, x_parser) in items.iter().enumerate() {
            let x_items = x_parser
                .get_ref(&builder.cache)
                .start_tokens(&builder.cache);
            for (y, y_parser) in items.iter().enumerate() {
                if x >= y {
                    continue;
                }
                let y_items = y_parser
                    .get_ref(&builder.cache)
                    .start_tokens(&builder.cache);
                let inter = x_items.intersection(&y_items).copied().collect::<Vec<_>>();
                for item in inter {
                    let set = if let Some(existing) = intersects.get_mut(&item) {
                        existing
                    } else {
                        intersects.insert(item, HashSet::new());
                        intersects.get_mut(&item).unwrap()
                    };
                    set.insert(x);
                    set.insert(y);
                }
            }
        }

        if !intersects.is_empty() {
            builder.error(&format!("Conficting options {intersects:?}"), self.0.span());
        }

        let has_named = items
            .iter()
            .any(|it| matches!(it.get_ref(&builder.cache), Parser::Named(_)));
        let mut options = Vec::new();
        for (token, parsers) in intersects {
            let rest = parsers
                .iter()
                .filter_map(|index| {
                    // TODO: Lots of issues here
                    let after = items[*index]
                        .get_ref(&builder.cache)
                        .clone()
                        .after_token(token, &mut builder.cache);
                    if let Some(after) = &after
                        && let Parser::Named(named) = after.get_ref(&builder.cache)
                    {
                        return Some(
                            Parser::Rename(Rename {
                                inner: named.inner.clone(),
                                name: named.name,
                            })
                            .cache(&mut builder.cache),
                        );
                    }
                    after
                })
                .collect::<Vec<_>>();
            let option = seq(
                vec![
                    just(token, &mut builder.cache),
                    choice(rest, &mut builder.cache),
                ],
                &mut builder.cache,
            );
            options.push(option);
        }
        choice(items, &mut builder.cache)
    }
}
