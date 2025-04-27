use crate::parser::{err::Expected, lang::Lang, res::PRes, state::ParserState};

use super::Parser;

#[derive(Debug, Clone)]
pub struct Choice<'src, L: Lang<'src>> {
    options: Vec<Parser<'src, L>>,
}

impl<'src, L: Lang<'src>> Choice<'src, L> {
    pub fn parse(&self, state: &mut ParserState<'src, L>, recover: bool) -> PRes {
        let mut res = self.options[0].peak(state, recover);
        if res.is_ok() {
            return self.options[0].do_parse(state, recover);
        }
        for option in &self.options[1..] {
            res = option.peak(state, recover);
            if res.is_ok() {
                return option.do_parse(state, recover);
            }
        }
        res
    }

    pub fn peak(&self, state: &ParserState<'src, L>, recover: bool) -> PRes {
        for p in &self.options {
            let res = p.peak(state, recover);
            if res.is_ok() {
                return PRes::Ok;
            } else if matches!(res, PRes::Break(_) | PRes::Eof) {
                return res;
            }
        }
        PRes::Err
    }

    pub fn expected(&self) -> Vec<Expected<'src, L>> {
        self.options.iter().flat_map(|it| it.expected()).collect()
    }
}

pub fn choice<'src, L: Lang<'src>>(options: Vec<Parser<'src, L>>) -> Parser<'src, L> {
    Parser::Choice(Choice { options })
}
