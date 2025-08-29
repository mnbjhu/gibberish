use crate::parser::{err::Expected, lang::Lang, res::PRes, state::ParserState};

use super::Parser;

#[derive(Debug, Clone, PartialEq)]
pub enum Requirement {
    Yes,
    No,
    Maybe,
}

impl Requirement {
    pub fn parse<L: Lang>(
        &self,
        parser: &Parser<L>,
        state: &mut ParserState<L>,
        recover: bool,
    ) -> PRes {
        match self {
            Requirement::Yes => parser.do_parse(state, recover),
            Requirement::No => PRes::Ok,
            Requirement::Maybe => {
                if parser.peak(state, recover, state.after_skip()) == PRes::Ok {
                    parser.do_parse(state, recover)
                } else {
                    PRes::Ok
                }
            }
        }
    }

    pub fn peak<L: Lang>(
        &self,
        parser: &Parser<L>,
        state: &ParserState<L>,
        recover: bool,
        offset: usize,
    ) -> PRes {
        match self {
            Requirement::Yes => parser.peak(state, recover, offset),
            Requirement::No => PRes::Ok,
            Requirement::Maybe => {
                let yes = parser.peak(state, recover, offset);
                if yes != PRes::Err { yes } else { PRes::Ok }
            }
        }
    }

    pub fn expected<L: Lang>(&self, parser: &Parser<L>) -> Vec<Expected<L>> {
        match self {
            Requirement::Yes | Requirement::Maybe => parser.expected(),
            Requirement::No => vec![],
        }
    }
}
