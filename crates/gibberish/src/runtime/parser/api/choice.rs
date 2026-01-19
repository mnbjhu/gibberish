use std::{iter::Peekable, ops::Range};

use tracing::instrument;

use crate::runtime::{
    lexer::edit::TokenEdit,
    parser::{Expected, Parser, node::Node, res::Res, state::State},
};

#[derive(Debug, Clone)]
pub struct Choice(pub Vec<Parser>);

impl Choice {
    #[instrument(name = "existing_choice", skip(self, input), ret, fields(next = input.peek().map(|it| it.name())))]
    pub fn from_existing<'a, I: Iterator<Item = Node<'a>>>(
        &'a self,
        input: &mut Peekable<I>,
    ) -> Option<Node<'a>> {
        let next = input.peek()?;
        let parser = self.0.iter().find(|it| it.peak_edit(next)).unwrap();
        parser.from_existing(input)
    }

    #[instrument(name = "parse_choice", skip(self, state), ret)]
    pub fn parse<'a, 't>(&'a self, offset: usize, state: &mut State<'a, 't>) -> Res<'a> {
        let mut res = Res::Err;
        for p in &self.0 {
            res = p.parse(offset, state);
            if matches!(res, Res::Ok(_)) {
                break;
            }
        }
        res
    }

    pub fn peak<'a, 't>(&self, offset: usize, state: &State<'a, 't>) -> bool {
        self.0.iter().any(|it| it.peak(offset, state))
    }

    #[instrument(name = "edit_choice", skip(self, state), ret)]
    pub fn edit<'a, 't>(
        &'a self,
        offset: usize,
        node: Node<'a>,
        state: &mut State<'a, 't>,
        edit: &mut TokenEdit,
        changed: &mut Range<usize>,
    ) -> Res<'a> {
        let parser = self.0.iter().find(|it| it.peak_edit(&node)).unwrap();
        parser.edit(offset, node, state, edit, changed)
    }

    pub fn peak_edit<'a>(&'a self, node: &Node<'a>) -> bool {
        self.0.iter().any(|it| it.peak_edit(node))
    }

    pub fn expected(&self) -> Vec<Expected> {
        self.0
            .iter()
            .flat_map(|it| it.expected().into_iter())
            .collect()
    }
}
