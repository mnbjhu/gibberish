use crate::parser::{err::Expected, lang::Lang, res::PRes, state::ParserState};

use super::Parser;

#[derive(Debug, Clone)]
pub struct Choice<L: Lang> {
    options: Vec<Parser<L>>,
}

impl<L: Lang> Choice<L> {
    pub fn parse(&self, state: &mut ParserState<L>, recover: bool) -> PRes {
        let mut res = self.options[0].peak(state, recover, state.after_skip());
        if res.is_ok() {
            return self.options[0].do_parse(state, recover);
        }
        for option in &self.options[1..] {
            res = option.peak(state, recover, state.after_skip());
            if res.is_ok() {
                return option.do_parse(state, recover);
            }
        }
        res
    }

    pub fn peak(&self, state: &ParserState<L>, recover: bool, offset: usize) -> PRes {
        for p in &self.options {
            let res = p.peak(state, recover, offset);
            if res.is_ok() {
                return PRes::Ok;
            } else if matches!(res, PRes::Break(_) | PRes::Eof) {
                return res;
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

impl<L: Lang> Parser<L> {
    pub fn or(self, other: Parser<L>) -> Parser<L> {
        if let Parser::Choice(mut options) = self {
            options.options.push(other);
            Parser::Choice(options)
        } else {
            choice(vec![self, other])
        }
    }
}
