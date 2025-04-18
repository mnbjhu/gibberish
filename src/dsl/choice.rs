use crate::parser::{err::Expected, lang::Lang, res::PRes, state::ParserState};

use super::Parser;

#[derive(Debug, Clone)]
pub struct Choice<L: Lang> {
    options: Vec<Parser<L>>,
}

impl<L: Lang> Choice<L> {
    pub fn parse(&self, state: &mut ParserState<L>, recover: bool) -> PRes {
        for option in &self.options {
            let res = option.peak(state, recover);
            if res.is_ok() {
                return option.do_parse(state, recover);
            } else if matches!(res, PRes::Break(_)) {
                return res
            }
        }
        PRes::Err
    }

    pub fn peak(&self, state: &ParserState<L>, recover: bool) -> PRes {
        for p in &self.options {
            let res = p.peak(state, recover);
            if res.is_ok() {
                return PRes::Ok;
            } else if matches!(res, PRes::Break(_)) {
                return res
            }
        }
        PRes::Err
    }

    pub fn expected(&self) -> Vec<Expected<L>> {
        self.options.iter().flat_map(|it| it.expected()).collect()
    }
}

pub fn choice<L: Lang>(options: Vec<Parser<L>>) -> Parser<L> {
    Parser::Choice(Choice { options })
}
