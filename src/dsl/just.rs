use crate::parser::{lang::Lang, res::PRes, state::ParserState};

#[derive(Clone)]
pub struct Just<L: Lang>(L::Token);

impl<L: Lang> Just<L> {
    pub fn parse(&self, state: &mut ParserState<L>) -> PRes {
        let tok = state.current().clone();
        if tok.kind == self.0 {
            PRes::Ok
        } else if let Some(pos) = state.try_delim() {
            PRes::Break(pos)
        } else {
            PRes::Err
        }
    }

    pub fn peak(&self, state: &mut ParserState<L>) -> PRes {
        let tok = state.current().clone();
        if tok.kind == self.0 {
            PRes::Ok
        } else if let Some(pos) = state.try_delim() {
            PRes::Break(pos)
        } else {
            PRes::Err
        }
    }
}
