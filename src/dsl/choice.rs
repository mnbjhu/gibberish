use crate::parser::{lang::Lang, res::PRes, state::ParserState};

use super::Parser;

pub struct Choice<L: Lang> {
    options: Vec<Parser<L>>,
}

impl<L: Lang> Choice<L> {
    pub fn parse(&self, state: &mut ParserState<L>) -> PRes {
        let Some(parser) = self.options.iter().find(|it| it.peak(state) != PRes::Err) else {
            return PRes::Err;
        };
        parser.parse(state)
    }
    pub fn peak(&self, state: &ParserState<L>) -> PRes {
        self.options
            .iter()
            .map(|it| it.peak(state))
            .find(|it| *it != PRes::Err)
            .unwrap_or(PRes::Err)
    }
}
