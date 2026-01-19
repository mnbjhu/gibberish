use std::iter::Peekable;

use tracing::{error, instrument};

use crate::runtime::{
    lexer::edit::TokenEdit,
    parser::{Expected, Parser, node::Node, res::Res, state::State},
};

#[derive(Debug, Clone)]
pub struct Rep(pub Box<Parser>);

impl Rep {
    #[instrument(name = "existing_rep", skip(self, input), ret, fields(next = input.peek().map(|it| it.name())))]
    pub fn from_existing<'a, I: Iterator<Item = Node<'a>>>(
        &'a self,
        input: &mut Peekable<I>,
    ) -> Option<Node<'a>> {
        let mut res = vec![];
        let mut len = 0;
        while let Some(item) = self.0.from_existing(input) {
            len += item.len();
            if let Node::List { items, .. } = item {
                res.extend(items);
            } else {
                res.push(item)
            }
            while let Some(Node::Unexpected(_)) = input.peek() {
                error!("Reusing unexpected");
                let next = input.next().unwrap();
                len += next.len();
                res.push(next);
            }
        }
        Some(Node::List { items: res, len })
    }

    #[instrument(name = "parse_rep", skip(self, state), ret)]
    pub fn parse<'a, 't>(&'a self, mut offset: usize, state: &mut State<'a, 't>) -> Res<'a> {
        let mut items = vec![];
        state.break_stack.push(&self.0);
        let break_index = state.break_stack.len();
        let res = self.0.parse(offset, state);
        match res {
            Res::Ok(node) => {
                offset += node.len();
                items.push(node);
            }
            Res::Break(index) => {
                state.break_stack.pop();
                if index == break_index {
                    return Res::Err;
                }
                return Res::Break(index);
            }
            Res::Err => {
                state.break_stack.pop();
                return Res::Err;
            }
        }
        finish_rep(&mut offset, state, &self.0, items)
    }

    pub fn peak<'a, 't>(&self, offset: usize, state: &State<'a, 't>) -> bool {
        self.0.peak(offset, state)
    }

    #[instrument(name = "edit_rep", skip(self, state), ret)]
    pub fn edit<'a, 't>(
        &'a self,
        mut offset: usize,
        items: Vec<Node<'a>>,
        state: &mut State<'a, 't>,
        edit: &mut TokenEdit,
        changed: &mut std::ops::Range<usize>,
    ) -> Res<'a> {
        let mut input = items.into_iter().peekable();
        let mut items = vec![];
        let mut next_existing_offset = 0;
        if let Some(first) = input.peek()
            && self.0.peak_edit(first)
        {
            state.break_stack.push(&self.0);
            while let Res::Ok(node) = self.0.try_edit(
                &mut offset,
                &mut next_existing_offset,
                &mut input,
                &mut items,
                state,
                edit,
                changed,
            ) {
                offset += node.len();
                items.push(node);
            }
            state.break_stack.pop();
            Res::Ok(Node::List {
                len: items.iter().map(|it| it.len()).sum(),
                items,
            })
        } else {
            self.parse(offset, state).update_changed(offset, changed)
        }
    }

    pub fn peak_edit<'a>(&'a self, node: &Node<'a>) -> bool {
        if let Node::List { items, .. } = node {
            items.first().is_some_and(|first| self.0.peak_edit(first))
        } else {
            self.0.peak_edit(node)
        }
    }
    pub fn expected(&self) -> Vec<Expected> {
        self.0.expected()
    }
}

pub fn finish_rep<'a, 't>(
    offset: &mut usize,
    state: &mut State<'a, 't>,
    inner: &'a Parser,
    mut items: Vec<Node<'a>>,
) -> Res<'a> {
    loop {
        let res = inner.try_parse(offset, state, &mut items);
        match res {
            Res::Ok(node) => {
                *offset += node.len();
                items.push(node);
            }
            _ => {
                state.break_stack.pop();
                return Res::Ok(Node::List {
                    len: items.iter().map(|it| it.len()).sum(),
                    items: items
                        .into_iter()
                        .flat_map(|it| {
                            if let Node::List { items, .. } = it {
                                items.into_iter()
                            } else {
                                vec![it].into_iter()
                            }
                        })
                        .collect(),
                });
            }
        }
    }
}
