use std::{iter::Peekable, ops::Range, ptr};

use tracing::{error, field, info};

use crate::runtime::{
    lexer::edit::TokenEdit,
    parser::{
        Parser,
        edit::{EditState, ExistingInput},
        node::Node,
        res::Res,
        state::State,
    },
};

pub mod choice;
pub mod just;
pub mod named;
pub mod rep;
pub mod seq;

impl Parser {
    pub fn get_existing<'a, 'i, 't, 's, I: Iterator<Item = Node<'a>>>(
        &'a self,
        input: &mut ExistingInput<'a, I>,
    ) -> Option<Node<'a>> {
        if let Some(Node::Missing(p)) = input.peek() {
            if !ptr::eq(*p, self) {
                error!(
                    "Expected {current} but found {missing}",
                    current = self.kind(),
                    missing = p.kind()
                );
            }
            let result = input.next();
            match &result {
                Some(node) => info!("Result: {node:?}"),
                None => info!("Result: Err"),
            };
            return result;
        }
        match self {
            Parser::Just(_) | Parser::Named { .. } => input.next(),
            Parser::Choice(choice) => choice.from_existing(input),
            Parser::Seq(seq) => seq.from_existing(input),
            Parser::Rep(rep) => rep.from_existing(input),
        }
    }

    pub fn edit<'a, 't, 's>(
        &'a self,
        node: Node<'a>,
        state: &mut EditState<'a, 't, 's>,
        next_existing_offset: usize,
    ) -> Res<'a> {
        info!("edit: {:?}", state.edit);
        let before = state.offset;
        if state.offset + node.len() < state.edit.remove.start
            || state.edit.remove.end <= state.offset
        {
            info!("Reusing {:?}", state.offset..state.offset + node.len());
            return Res::Ok(node);
        }
        if state.edit.remove.start <= state.offset {
            info!("Reparsing {:?}", state.offset..state.offset + node.len());
            return self.parse(state.offset, state.state);
        }
        let res = match (self, node) {
            (_, Node::Missing(p)) => {
                if !ptr::eq(p, self) {
                    error!("Missing didn't match self")
                }
                p.parse(state.offset, state.state)
            }
            (Parser::Choice(choice), node) => choice.edit(node, state, next_existing_offset),
            (Parser::Just(_), Node::Token(_)) => self.parse(state.offset, state.state),
            (Parser::Seq(seq), Node::List { items, .. }) => {
                seq.edit(state, items, next_existing_offset)
            }
            (Parser::Rep(rep), Node::List { items, .. }) => {
                rep.edit(state, items, next_existing_offset)
            }

            (Parser::Named(named), Node::Group { children, .. }) => {
                named.edit(state, children, next_existing_offset)
            }
            (_, _) => panic!("Unexpected parser/node combo"),
        };
        state.offset = before;
        res
    }

    #[allow(clippy::too_many_arguments)]
    pub fn try_edit<'a, 't, 's, I: Iterator<Item = Node<'a>>>(
        &'a self,
        input: &mut ExistingInput<'a, I>,
        new: &mut Vec<Node<'a>>,
        state: &mut EditState<'a, 't, 's>,
    ) -> Res<'a> {
        let _span = tracing::span!(
            tracing::Level::INFO,
            "try_edit",
            offset = state.offset,
            next = input.peek().map(|it| it.name()),
            next_existing_offset = input.existing_offset,
            parser = self.kind()
        )
        .entered();

        loop {
            let offset_in_existing = if state.offset >= state.edit.remove.start {
                isize::try_from(state.offset).unwrap() - state.edit.change()
            } else {
                isize::try_from(state.offset).unwrap()
            };
            info!(
                name = "Existing check",
                state.offset,
                offset_in_existing,
                edit = field::debug(&state.edit)
            );
            if offset_in_existing > isize::try_from(input.existing_offset).unwrap()
                && input.peek().is_some()
            {
                let next = input.next().unwrap();
                info!("Skipping {next:?}");
                continue;
            }
            let start_existing_offset = input.existing_offset;
            let res = if isize::try_from(start_existing_offset).unwrap() == offset_in_existing
                && let Some(next) = self.get_existing(input)
            {
                let before_len = next.len();
                let end = state.offset + before_len;

                if let Node::Missing(p) = next {
                    if !ptr::eq(p, self) {
                        error!(
                            "Expected {current} but found {missing}",
                            current = self.kind(),
                            missing = p.kind()
                        );
                    };
                    info!("Replacing missing");
                    p.parse(state.offset, state.state).map(|it| {
                        info!("Found missing");
                        it
                    })
                } else {
                    // If the edit's remove contains 'next' we just delete it from the tree
                    if state.edit.remove.start <= state.offset && end <= state.edit.remove.end {
                        info!("Deleting {:?}", state.offset..end);
                        continue;
                    }
                    let next_len = next.len();

                    // If we're before or after the edit we can just use the existing
                    if state.edit.remove.start >= end || state.edit.remove.end <= state.offset {
                        info!(
                            "Reusing (try) {:?}, next_len: {next_len}, offset: {offset}, next_existing_offset: {next_existing_offset}",
                            state.offset..end,
                            next_len = next_len,
                            offset = state.offset,
                            next_existing_offset = input.existing_offset
                        );
                        if let Node::Unexpected(n) = next {
                            state.offset += n;
                            new.push(Node::Unexpected(n));
                            continue;
                        } else {
                            info!("Result: {next:?}");
                            return Res::Ok(next);
                        }
                    }

                    let res = if state.offset <= state.edit.remove.start
                        && state.edit.remove.start < end
                    {
                        // If the the edit starts in the item then perform an edit
                        info!("Editing (try) {:?}", state.offset..end);
                        self.edit(next, state, start_existing_offset)
                    } else {
                        info!("Reparsing (try) {:?}", state.offset..end);
                        self.parse(state.offset, state.state)
                    };
                    res
                }
            } else {
                self.parse(state.offset, state.state)
            };
            if !matches!(res, Res::Err) {
                match &res {
                    Res::Ok(node) => info!("Result: {node:?}"),
                    Res::Err => info!("Result: Err"),
                    Res::Break(idx) => info!("Result: Break({})", idx),
                };
                return res;
            } else if let Some(Node::Unexpected(n)) = new.last_mut() {
                *n += 1;
                state.offset += 1;
            } else {
                state.offset += 1;
                error!("Bump error");
                new.push(Node::Unexpected(1));
            }
        }
    }

    pub fn peak_edit<'a>(&'a self, node: &Node<'a>) -> bool {
        match self {
            Parser::Just(tok) => tok.peak_edit(node),
            Parser::Choice(c) => c.peak_edit(node),
            Parser::Seq(s) => s.peak_edit(node),
            Parser::Rep(r) => r.peak_edit(node),
            Parser::Named(n) => n.peak_edit(node),
        }
    }
}
