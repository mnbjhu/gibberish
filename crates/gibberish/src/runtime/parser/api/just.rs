use tracing::instrument;

use crate::runtime::parser::{Expected, node::Node, res::Res, state::State};

#[derive(Debug, Clone)]
pub struct Just(pub u32);

impl Just {
    #[instrument(name = "parse_just", skip(self, state), ret)]
    pub fn parse<'a, 't>(&'a self, offset: usize, state: &mut State<'a, 't>) -> Res<'a> {
        if let Some(current) = state.token_at(offset) {
            if current == self.0 {
                Res::Ok(Node::Token(self.0))
            } else if let Some(index) = state.get_break(offset) {
                let b = index + 1;
                Res::Break(b)
            } else {
                Res::Err
            }
        } else {
            Res::Break(0)
        }
    }

    pub fn peak<'a, 't>(&self, offset: usize, state: &State<'a, 't>) -> bool {
        state.token_at(offset).is_some_and(|it| it == self.0)
    }

    pub fn peak_edit<'a>(&'a self, node: &Node<'a>) -> bool {
        if let Node::Token(id) = node {
            self.0 == *id
        } else {
            false
        }
    }
    pub fn expected(&self) -> Vec<Expected> {
        vec![Expected::Token(self.0)]
    }
}
