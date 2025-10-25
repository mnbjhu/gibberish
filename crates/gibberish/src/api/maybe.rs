use crate::parser::{err::Expected, lang::Lang, res::PRes, state::ParserState};

use super::Parser;

#[derive(Debug, Clone, PartialEq, Hash, Eq)]
pub enum Requirement {
    Yes,
    No,
    Maybe,
}

impl<'a> Requirement {
    pub fn parse<L: Lang>(
        &self,
        parser: &'a Parser<L>,
        next: &'a Parser<L>,
        state: &mut ParserState<'a, L>,
        recover: bool,
    ) -> (bool, PRes) {
        match self {
            Requirement::Yes => (true, parser.do_parse(state, recover)),
            Requirement::No => (false, next.do_parse(state, recover)),
            Requirement::Maybe => {
                if parser.do_parse(state, recover).is_ok() {
                    return (true, PRes::Ok);
                } else {
                    (false, next.do_parse(state, recover))
                }
            }
        }
    }

    pub fn peak<L: Lang>(
        &self,
        parser: &Parser<L>,
        next: &Parser<L>,
        state: &ParserState<L>,
        recover: bool,
        offset: usize,
    ) -> PRes {
        match self {
            Requirement::Yes => parser.peak(state, recover, offset),
            Requirement::No => next.peak(state, recover, offset),
            Requirement::Maybe => {
                if parser.peak(state, recover, offset).is_ok() {
                    PRes::Ok
                } else {
                    next.peak(state, recover, offset)
                }
            }
        }
    }

    pub fn expected<L: Lang>(
        &self,
        parser: &Parser<L>,
        next: &Parser<L>,
        state: &ParserState<'a, L>,
    ) -> Vec<Expected<L>> {
        match self {
            Requirement::Yes => parser.expected(state),
            Requirement::No => next.expected(state),
            Requirement::Maybe => {
                let mut res = parser.expected(state);
                res.extend(next.expected(state));
                res
            }
        }
    }
}
