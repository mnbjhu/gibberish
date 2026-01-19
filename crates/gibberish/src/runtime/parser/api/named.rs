use tracing::instrument;

use crate::runtime::{
    lexer::edit::TokenEdit,
    parser::{Expected, Parser, node::Node, res::Res, state::State},
};

#[derive(Debug, Clone)]
pub struct Named {
    pub name: u32,
    pub inner: Box<Parser>,
}

impl Named {
    #[instrument(name = "parse_named", skip(self, state), ret)]
    pub fn parse<'a, 't>(&'a self, offset: usize, state: &mut State<'a, 't>) -> Res<'a> {
        state.checkpoints.push(state.break_stack.len());
        let res = match self.inner.parse(offset, state) {
            Res::Ok(node) => {
                let mut children = vec![];
                node.add_into(&mut children);
                Res::Ok(Node::Group {
                    kind: self.name,
                    len: children.iter().map(Node::len).sum(),
                    children,
                })
            }
            res => res,
        };
        state.checkpoints.pop();
        res
    }

    pub fn peak<'a, 't>(&self, offset: usize, state: &State<'a, 't>) -> bool {
        self.inner.peak(offset, state)
    }

    #[instrument(name = "edit_named", skip(self, state), ret)]
    pub fn edit<'a, 't>(
        &'a self,
        offset: usize,
        children: Vec<Node<'a>>,
        state: &mut State<'a, 't>,
        edit: &mut TokenEdit,
        changed: &mut std::ops::Range<usize>,
    ) -> Res<'a> {
        let child = self
            .inner
            .from_existing(&mut children.into_iter().peekable())
            .unwrap();
        let name = self.name;
        self.inner
            .edit(offset, child, state, edit, changed)
            .map(|it| {
                let len = it.len();
                let children = if let Node::List { items, .. } = it {
                    items
                } else {
                    vec![it]
                };
                Node::Group {
                    kind: name,
                    children,
                    len,
                }
            })
    }

    pub fn peak_edit<'a>(&'a self, node: &Node<'a>) -> bool {
        if let Node::Group { kind, .. } = node {
            self.name == *kind
        } else {
            false
        }
    }

    pub fn expected(&self) -> Vec<Expected> {
        vec![Expected::Syntax(self.name)]
    }
}
