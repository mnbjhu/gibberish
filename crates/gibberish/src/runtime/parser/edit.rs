use std::iter::Peekable;

use tracing::info;

use crate::runtime::{
    lexer::edit::TokenEdit,
    parser::{Parser, node::Node, res::Res, state::State},
};

impl Parser {
    pub fn try_edit<'a, 't>(
        &'a self,
        existing: &mut Peekable<impl Iterator<Item = Node<'a>>>,
        new: &mut Vec<Node<'a>>,
        index: usize,
        edit: &mut TokenEdit,
        state: &mut State<'a, 't>,
    ) -> Res<'a> {
        match self {
            Parser::Just(tok) => self.parse(index, state),
            Parser::Choice(parsers) => {
                todo!()
            }
            Parser::Seq(parsers) => todo!(),
            Parser::Rep(parser) => todo!(),
            Parser::Named { name, inner } => todo!(),
        }
    }

    pub fn peak_edit<'a>(&'a self, node: &Node<'a>) -> bool {
        match self {
            Parser::Just(tok) => {
                if let Node::Token(id) = node
                    && tok == id
                {
                    true
                } else {
                    false
                }
            }
            Parser::Choice(parsers) => parsers.iter().any(|it| it.peak_edit(node)),
            Parser::Seq(parsers) => parsers.first().unwrap().peak_edit(node),
            Parser::Rep(parser) => parser.peak_edit(node),
            Parser::Named { name, .. } => {
                if let Node::Group { kind, .. } = node
                    && name == kind
                {
                    true
                } else {
                    false
                }
            }
        }
    }

    pub fn edit<'a, 't>(
        &'a self,
        node: Node<'a>,
        index: usize,
        mut edit: TokenEdit,
        state: &mut State<'a, 't>,
    ) -> Res<'a> {
    }
}

impl<'a> Res<'a> {
    pub fn map(self, f: fn(Node<'a>) -> Node<'a>) -> Res<'a> {
        match self {
            Res::Ok(node) => Res::Ok(f(node)),
            res => res,
        }
    }
}

impl<'a> Node<'a> {
    pub fn edit<'t>(
        self,
        index: usize,
        edit: &TokenEdit,
        state: &mut State<'a, 't>,
    ) -> (Option<Res<'a>>, Option<usize>) {
        match self {
            Node::Unexpected(len) => (None, None),
            Node::Missing(parser) => (None, None),
            Node::Token(_) => (None, None),
            Node::List { items, len } => todo!(),
            Node::Group {
                mut children,
                parser,
                kind,
                len,
                breaks_from_parent,
            } => {
                let mut off = index;
                info!(
                    "Editing {kind}@{span:?} at {index} with {edit:?}",
                    span = off..off + len
                );
                let mut s = None;
                for i in 0..children.len() {
                    let child_len = children[i].len();
                    let span = off..off + child_len;
                    info!("Checking child {i}@{span:?}");
                    if span.contains(&edit.remove.start) {
                        if edit.remove.end > off + child_len {
                            info!("Edit if after token end");
                            return (None, None);
                        }
                        let Node::Group { parser: inner, .. } = children[i] else {
                            return (None, None);
                        };
                        let expected_len = isize::try_from(child_len).unwrap() + edit.change();
                        for b in &breaks_from_parent {
                            state.break_stack.push(b);
                        }
                        let new =
                            if let (Some(res), start) = children.remove(i).edit(off, edit, state) {
                                s = start;
                                res
                            } else {
                                inner.parse(off, state)
                            };
                        for _ in &breaks_from_parent {
                            state.break_stack.pop();
                        }
                        if let Res::Ok(new) = new {
                            if usize::try_from(expected_len).unwrap() == new.len() {
                                children.insert(i, new);
                                info!("New matches the edit size");
                                break;
                            }
                            info!(
                                "Failed to parse new {new_len} != {expected_len} (new != expected)",
                                new_len = new.len()
                            );
                        }
                        info!("Parse failed with err",);
                        return (None, None);
                    }
                    off += child_len;
                }
                info!("Done {kind}");
                (
                    Some(Res::Ok(Node::Group {
                        kind,
                        children,
                        len: usize::try_from(isize::try_from(len).unwrap() + edit.change())
                            .unwrap(),
                        parser,
                        breaks_from_parent,
                    })),
                    Some(s.unwrap_or(off)),
                )
            }
        }
    }
}
