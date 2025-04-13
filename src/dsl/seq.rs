use crate::parser::{err::Expected, lang::Lang, res::PRes, state::ParserState};

use super::Parser;

#[derive(Clone)]
pub struct Seq<L: Lang>(Vec<Parser<L>>);

impl<L: Lang> Seq<L> {
    pub fn parse(&self, state: &mut ParserState<L>) -> PRes {
        let start = self.peak(state);
        if start.is_err() {
            return start;
        }
        for p in &self.0 {
            let res = state.try_parse(p);
            if res.is_err() {
                return res;
            }
        }
        PRes::Ok
    }

    pub fn peak(&self, state: &ParserState<L>) -> PRes {
        self.0
            .first()
            .expect("Seq should have at least one element")
            .peak(state)
    }

    pub fn expected(&self) -> Vec<Expected<L>> {
        self.0
            .first()
            .expect("Seq should have at least one element")
            .expected()
    }
}

pub fn seq<L: Lang>(parts: Vec<Parser<L>>) -> Parser<L> {
    Parser::Seq(Seq(parts))
}
