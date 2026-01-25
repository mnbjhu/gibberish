use std::iter::Peekable;

use tracing::{error, instrument};

use crate::runtime::{
    lexer::edit::TokenEdit,
    parser::{Expected, Parser, node::Node, res::Res, state::State},
};

#[derive(Debug, Clone)]
pub struct Seq(pub Vec<Parser>);

impl Seq {
    #[instrument(name = "existing_seq", skip(self, input), ret, fields(next = input.peek().map(|it| it.name())))]
    pub fn from_existing<'a, I: Iterator<Item = Node<'a>>>(
        &'a self,
        input: &mut Peekable<I>,
    ) -> Option<Node<'a>> {
        let mut res = Vec::new();
        let mut len = 0;
        for p in &self.0 {
            while let Some(Node::Unexpected(_)) = input.peek() {
                error!("Reusing unexpected");
                let next = input.next().unwrap();
                len += next.len();
                res.push(next);
            }
            let part = p.get_existing(input).unwrap();
            len += part.len();
            if let Node::List { items, .. } = part {
                res.extend(items);
            } else {
                res.push(part)
            }
        }
        Some(Node::List { items: res, len })
    }

    #[instrument(name = "parse_seq", skip(self, state), ret)]
    pub fn parse<'a, 't>(&'a self, mut offset: usize, state: &mut State<'a, 't>) -> Res<'a> {
        let mut nodes = vec![];
        let lowest_break = 1 + state.break_stack.len();
        let highest_break = lowest_break + self.0.len() - 2;
        self.0[1..]
            .iter()
            .rev()
            .for_each(|it| state.break_stack.push(it));
        let mut res = self.0[0].parse(offset, state);
        if !matches!(res, Res::Ok(_)) {
            self.0[1..].iter().for_each(|_| {
                state.break_stack.pop();
            });
            if let Res::Break(index) = res
                && index >= lowest_break
            {
                return Res::Err;
            } else {
                return res;
            }
        }
        for (i, p) in self.0[1..].iter().enumerate() {
            let break_index = highest_break - i;
            state.break_stack.pop();
            if let Res::Ok(node) = res {
                offset += node.len();
                nodes.push(node);
                res = p.try_parse(&mut offset, state, &mut nodes);
                if matches!(res, Res::Break(_)) {
                    nodes.push(Node::Missing(p));
                }
            } else if let Res::Break(index) = res
                && index == break_index
            {
                res = p.try_parse(&mut offset, state, &mut nodes);
            } else {
                nodes.push(Node::Missing(p));
            }
        }
        if let Res::Ok(node) = res {
            nodes.push(node);
        }
        Res::Ok(Node::List {
            len: nodes.iter().map(|it| it.len()).sum(),
            items: nodes,
        })
    }

    pub fn peak<'a, 't>(&self, offset: usize, state: &State<'a, 't>) -> bool {
        self.0.first().is_some_and(|it| it.peak(offset, state))
    }

    pub fn peak_edit<'a>(&'a self, node: &Node<'a>) -> bool {
        if let Node::List { items, .. } = node {
            items
                .first()
                .is_some_and(|first| self.0.first().unwrap().peak_edit(first))
        } else {
            self.0.first().unwrap().peak_edit(node)
        }
    }

    #[instrument(name = "edit_seq", skip(self, state), ret)]
    pub fn edit<'a, 't>(
        &'a self,
        mut offset: usize,
        items: Vec<Node<'a>>,
        state: &mut State<'a, 't>,
        edit: &mut TokenEdit,
        changed: &mut std::ops::Range<usize>,
        mut next_existing_offset: usize,
    ) -> Res<'a> {
        if !self.peak_edit(&items[0]) {
            return self.parse(offset, state);
        }
        let mut input = items.into_iter().peekable();
        let mut nodes = vec![];
        let lowest_break = 1 + state.break_stack.len();
        let highest_break = lowest_break + self.0.len() - 2;
        self.0[1..]
            .iter()
            .rev()
            .for_each(|it| state.break_stack.push(it));
        let mut res = self.0[0].try_edit(
            &mut offset,
            &mut next_existing_offset,
            &mut input,
            &mut nodes,
            state,
            edit,
            changed,
        );
        if !matches!(res, Res::Ok(_)) {
            self.0[1..].iter().for_each(|_| {
                state.break_stack.pop();
            });
            if let Res::Break(index) = res
                && index >= lowest_break
            {
                return Res::Err;
            } else {
                return res;
            }
        }
        for (i, p) in self.0[1..].iter().enumerate() {
            let break_index = highest_break - i;
            state.break_stack.pop();
            if let Res::Ok(node) = res {
                offset += node.len();
                nodes.push(node);
                res = p.try_edit(
                    &mut offset,
                    &mut next_existing_offset,
                    &mut input,
                    &mut nodes,
                    state,
                    edit,
                    changed,
                );
                if matches!(res, Res::Break(_)) {
                    nodes.push(Node::Missing(p));
                }
            } else if let Res::Break(index) = res
                && index == break_index
            {
                res = p.try_edit(
                    &mut offset,
                    &mut next_existing_offset,
                    &mut input,
                    &mut nodes,
                    state,
                    edit,
                    changed,
                )
            } else {
                nodes.push(Node::Missing(p));
            }
        }
        if let Res::Ok(node) = res {
            nodes.push(node);
        }
        Res::Ok(Node::List {
            len: nodes.iter().map(|it| it.len()).sum(),
            items: nodes,
        })
    }

    pub fn expected(&self) -> Vec<Expected> {
        self.0.first().unwrap().expected()
    }
}
