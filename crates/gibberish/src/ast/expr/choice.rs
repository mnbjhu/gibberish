use std::{
    collections::{HashMap, HashSet},
    u32,
};

use gibberish_core::node::Group;
use gibberish_gibberish_parser::Gibberish;
use tracing::info;

use crate::{
    ast::{builder::ParserBuilder, expr::ExprAst},
    parser::{
        Parser,
        checkpoint::Checkpoint,
        choice::{Choice, choice as build_choice},
        just::just,
        ptr::ParserIndex,
        seq::seq,
    },
};

#[derive(Clone, Copy)]
pub struct ChoiceAst<'a>(pub &'a Group<Gibberish>);

impl<'a> ChoiceAst<'a> {
    pub fn iter(&self) -> impl Iterator<Item = ExprAst<'a>> {
        self.0.green_children().map(ExprAst::from)
    }

    pub fn build(&self, builder: &mut ParserBuilder) -> ParserIndex {
        let items = self.iter().map(|it| it.build(builder)).collect::<Vec<_>>();
        build_choice(items, &mut builder.cache)
    }
}

impl ParserIndex {
    pub fn reduce_conflicts(
        &self,
        builder: &mut ParserBuilder,
        depth: usize,
    ) -> Option<ParserIndex> {
        if depth == 64 {
            panic!("Failed to reduce conflicts after 64 iterations")
        }
        if let Parser::Choice(choice) = self.get_ref(&builder.cache).clone() {
            let mut intersects = HashMap::<u32, HashSet<usize>>::new();
            for (x, x_parser) in choice.options.iter().enumerate() {
                let x_items = x_parser
                    .get_ref(&builder.cache)
                    .start_tokens(&builder.cache);
                for (y, y_parser) in choice.options.iter().enumerate() {
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
            if intersects.is_empty() {
                return Some(self.clone());
            }

            info!("Reducing intersects {self:?}: {intersects:?}");
            let has_named = choice
                .options
                .iter()
                .any(|it| matches!(it.get_ref(&builder.cache), Parser::Named(_)));
            let require_named = choice
                .options
                .iter()
                .all(|it| matches!(it.get_ref(&builder.cache), Parser::Named(_)));
            let mut options = Vec::new();
            for (token, parsers) in intersects {
                let option = choice.after_token(token, builder)?;
                options.push(option);
            }
            for item in choice.options {
                options.push(item);
            }
            let p = build_choice(options, &mut builder.cache);
            info!("Done");
            if has_named {
                Some(Parser::Checkpoint(Checkpoint(p)).cache(&mut builder.cache))
            } else {
                Some(p)
            }
        } else {
            Some(self.clone())
        }
    }
}

impl Choice {}
