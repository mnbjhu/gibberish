use crate::parser::{err::Expected, lang::Lang, res::PRes, state::ParserState};

use super::Parser;

#[derive(Clone)]
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
        for p in &self.options {
            let res = p.peak(state);
            if res.is_ok() {
                return PRes::Ok;
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
