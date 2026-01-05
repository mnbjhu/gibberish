use tracing::info;

use crate::runtime::{
    lexer::edit::TokenEdit,
    parser::{node::Node, res::Res, state::State},
};

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
            Node::Token => (None, None),
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
