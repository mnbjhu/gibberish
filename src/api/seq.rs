use crate::parser::{err::Expected, lang::Lang, res::PRes, state::ParserState};

use super::Parser;

#[derive(Debug, Clone)]
pub struct Seq<'src, L: Lang<'src>>(Vec<Parser<'src, L>>);

impl<'src, L: Lang<'src>> Seq<'src, L> {
    pub fn parse(&self, state: &mut ParserState<'src, L>, recover: bool) -> PRes {
        let start = self.peak(state, recover);
        if start.is_err() {
            return start;
        }
        for p in &self.0 {
            let res = state.try_parse(p, recover);
            match res {
                PRes::Break(_) => {
                    state.missing(p);
                    return PRes::Ok;
                }
                PRes::Ok => continue,
                PRes::Eof | PRes::Err => return PRes::Ok,
            }
        }
        PRes::Ok
    }

    pub fn peak(&self, state: &ParserState<'src, L>, recover: bool) -> PRes {
        self.0
            .first()
            .expect("Seq should have at least one element")
            .peak(state, recover)
    }

    pub fn expected(&self) -> Vec<Expected<'src, L>> {
        self.0
            .first()
            .expect("Seq should have at least one element")
            .expected()
    }
}

pub fn seq<'src, L: Lang<'src>>(parts: Vec<Parser<'src, L>>) -> Parser<'src, L> {
    Parser::Seq(Seq(parts))
}
