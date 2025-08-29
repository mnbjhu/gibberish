use crate::parser::{err::Expected, lang::Lang, res::PRes, state::ParserState};

use super::Parser;

#[derive(Debug, Clone)]
pub struct Choice<L: Lang> {
    options: Vec<Parser<L>>,
}

impl<L: Lang> Choice<L> {
    pub fn parse(&self, state: &mut ParserState<L>, recover: bool) -> PRes {
        let mut res = self.options[0].do_parse(state, recover);
        if res.is_ok() {
            return self.options[0].do_parse(state, recover);
        }
        for option in &self.options[1..] {
            res = option.do_parse(state, recover);
            if res.is_ok() {
                return option.do_parse(state, recover);
            }
        }
        res
    }

    pub fn expected(&self) -> Vec<Expected<L>> {
        self.options.iter().flat_map(|it| it.expected()).collect()
    }
}

pub fn choice<L: Lang>(options: Vec<Parser<L>>) -> Parser<L> {
    Parser::Choice(Choice { options })
}
