use std::collections::{HashMap, HashSet};

use gibberish_core::node::Group;
use gibberish_gibberish_parser::Gibberish;
use tracing::info;

use crate::{
    ast::{builder::ParserBuilder, expr::ExprAst},
    parser::{
        Parser,
        checkpoint::Checkpoint,
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

impl Parser {
    pub fn reduce_conflicts(&self, builder: &mut ParserBuilder, depth: usize) -> Option<Parser> {
        if depth == 64 {
            panic!("Failed to reduce conflicts after 64 iterations")
        }
        if let Parser::Choice(choice) = self.clone() {
            let mut intersects = HashMap::<String, HashSet<usize>>::new();
            for (x, x_parser) in choice.options.iter().enumerate() {
                let x_items = x_parser.start_tokens(&builder);
                for (y, y_parser) in choice.options.iter().enumerate() {
                    if x >= y {
                        continue;
                    }
                    let y_items = y_parser.start_tokens(&builder);
                    let inter = x_items.intersection(&y_items).collect::<Vec<_>>();
                    for item in inter {
                        let set = if let Some(existing) = intersects.get_mut(item) {
                            existing
                        } else {
                            intersects.insert(item.clone(), HashSet::new());
                            intersects.get_mut(item).unwrap()
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
                .any(|it| matches!(it, Parser::Named(_)));
            let require_named = choice
                .options
                .iter()
                .all(|it| matches!(it, Parser::Named(_)));
            let mut options = Vec::new();
            for (token, parsers) in intersects {
                let option = choice.after_token(token.as_str(), builder)?;
                options.push(option);
            }
            for item in choice.options {
                options.push(item);
            }
            let p = build_choice(options);
            info!("Done");
            if has_named {
                Some(Parser::Checkpoint(Checkpoint(Box::new(p))))
            } else {
                Some(p)
            }
        } else {
            Some(self.clone())
        }
    }
}

impl Choice {}
