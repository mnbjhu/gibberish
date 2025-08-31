use crate::parser::{err::Expected, lang::Lang, res::PRes, state::ParserState};

use super::Parser;

#[derive(Debug, Clone)]
pub struct Seq<L: Lang>(Vec<Parser<L>>);

impl<L: Lang> Seq<L> {
    pub fn parse(&self, state: &mut ParserState<L>, recover: bool) -> PRes {
        let start = self.peak(state, recover, state.after_skip());
        if start.is_err() {
            return start;
        }
        for p in &self.0 {
            let (res, bumped) = state.try_parse(p, recover);
            match res {
                PRes::Break(_) => {
                    if !bumped {
                        state.missing(p);
                    }
                    return PRes::Ok;
                }
                PRes::Ok => continue,
                PRes::Eof | PRes::Err => return PRes::Ok,
            }
        }
        PRes::Ok
    }

    pub fn peak(&self, state: &ParserState<L>, recover: bool, offset: usize) -> PRes {
        self.0
            .first()
            .expect("Seq should have at least one element")
            .peak(state, recover, offset)
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
