use std::{iter::Peekable, ops::Range, ptr};

use tracing::{error, field, info};

use crate::runtime::{
    lexer::edit::TokenEdit,
    parser::{Parser, node::Node, res::Res, state::State},
};

pub mod choice;
pub mod just;
pub mod named;
pub mod rep;
pub mod seq;

impl Parser {
    pub fn get_existing<'a, 'i, 't, 's, I: Iterator<Item = Node<'a>>>(
        &'a self,
        input: &mut Peekable<I>,
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

    pub fn edit<'a, 't>(
        &'a self,
        offset: usize,
        node: Node<'a>,
        state: &mut State<'a, 't>,
        edit: &mut TokenEdit,
        changed: &mut Range<usize>,
        next_existing_offset: usize,
    ) -> Res<'a> {
        info!("edit: {:?}", edit);
        if offset + node.len() < edit.remove.start || edit.remove.end <= offset {
            info!("Reusing {:?}", offset..offset + node.len());
            return Res::Ok(node);
        }
        if edit.remove.start <= offset {
            info!("Reparsing {:?}", offset..offset + node.len());
            return self.parse(offset, state).update_changed(offset, changed);
        }
        match (self, node) {
            (_, Node::Missing(p)) => {
                if !ptr::eq(p, self) {
                    error!("Missing didn't match self")
                }
                p.parse(offset, state)
            }
            (Parser::Choice(choice), node) => {
                choice.edit(offset, node, state, edit, changed, next_existing_offset)
            }
            (Parser::Just(_), Node::Token(_)) => {
                self.parse(offset, state).update_changed(offset, changed)
            }
            (Parser::Seq(seq), Node::List { items, .. }) => {
                seq.edit(offset, items, state, edit, changed, next_existing_offset)
            }
            (Parser::Rep(rep), Node::List { items, .. }) => {
                rep.edit(offset, items, state, edit, changed, next_existing_offset)
            }

            (Parser::Named(named), Node::Group { children, .. }) => {
                named.edit(offset, children, state, edit, changed, next_existing_offset)
            }
            (_, _) => panic!("Unexpected parser/node combo"),
        }
    }

    #[allow(clippy::too_many_arguments)]
    pub fn try_edit<'a, 't, I: Iterator<Item = Node<'a>>>(
        &'a self,
        offset: &mut usize,
        next_existing_offset: &mut usize,
        input: &mut Peekable<I>,
        new: &mut Vec<Node<'a>>,
        state: &mut State<'a, 't>,
        edit: &mut TokenEdit,
        changed: &mut Range<usize>,
    ) -> Res<'a> {
        let _span = tracing::span!(
            tracing::Level::INFO,
            "try_edit",
            offset = offset,
            next_existing_offset = *next_existing_offset,
            next = input.peek().map(|it| it.name()),
            parser = self.kind()
        )
        .entered();

        loop {
            let next_offset = if *offset >= edit.remove.start
                && edit.is_empty()
                && !matches!(input.peek(), Some(Node::Missing(_)))
            {
                isize::try_from(*next_existing_offset).unwrap() + edit.change()
            } else {
                isize::try_from(*next_existing_offset).unwrap()
            };
            info!(
                name = "Existing check",
                offset,
                next_offset,
                edit = field::debug(&edit)
            );
            if next_offset < isize::try_from(*offset).unwrap() && input.peek().is_some() {
                let next = input.next().unwrap();
                info!("Skipping {next:?}");
                if next.len() > edit.remove.len() {
                    let insert = next.len() - edit.remove.len();
                    edit.remove.end = edit.remove.start;
                    edit.insert += insert;
                } else {
                    edit.remove.end -= next.len();
                }
                continue;
            }
            let res = if isize::try_from(*offset).unwrap() == next_offset
                && let Some(next) = self.get_existing(input)
            {
                let before_len = next.len();
                let end = *offset + before_len;

                if let Node::Missing(p) = next {
                    if !ptr::eq(p, self) {
                        error!(
                            "Expected {current} but found {missing}",
                            current = self.kind(),
                            missing = p.kind()
                        );
                    };
                    info!("Replacing missing");
                    p.parse(*offset, state).map(|it| {
                        info!("Found missing");
                        let len = it.len();
                        *next_existing_offset += len;
                        if len > edit.remove.len() {
                            let extra = len - edit.remove.len();
                            edit.remove.end = edit.remove.start;
                            // TODO: Check for overflow??
                            edit.insert -= extra;
                        } else {
                            edit.remove.end -= len;
                        }
                        it
                    })
                } else {
                    // If the edit's remove contains 'next' we just delete it from the tree
                    if edit.remove.start <= *offset && end <= edit.remove.end {
                        info!("Deleting {:?}", *offset..end);
                        if next.len() > edit.remove.len() {
                            let extra = next.len() - edit.remove.len();
                            edit.remove.end = edit.remove.start;
                            // TODO: Check for overflow??
                            edit.insert -= extra;
                        } else {
                            edit.remove.end -= next.len();
                        }
                        continue;
                    }
                    let next_len = next.len();

                    // If we're before or after the edit we can just use the existing
                    if edit.remove.start >= end || edit.remove.end <= *offset {
                        info!(
                            "Reusing (try) {:?}, next_len: {next_len}, offset: {offset}, next_existing_offset: {next_existing_offset}",
                            *offset..end,
                            next_len = next_len,
                            offset = offset
                        );
                        *next_existing_offset += next_len;
                        if let Node::Unexpected(n) = next {
                            *offset += n;
                            new.push(Node::Unexpected(n));
                            continue;
                        } else {
                            info!("Result: {next:?}");
                            return Res::Ok(next);
                        }
                    }

                    let res = if *offset <= edit.remove.start && edit.remove.start < end {
                        // If the the edit starts in the item then perform an edit
                        info!("Editing (try) {:?}", *offset..end);
                        self.edit(*offset, next, state, edit, changed, *next_existing_offset)
                    } else {
                        info!("Reparsing (try) {:?}", *offset..end);
                        self.parse(*offset, state).update_changed(*offset, changed)
                    };
                    *next_existing_offset += next_len;
                    res
                }
            } else {
                self.parse(*offset, state).update_changed(*offset, changed)
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
                *offset += 1;
            } else {
                *offset += 1;
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
