use crate::parser::{err::Expected, lang::Lang, res::PRes, state::ParserState};

use super::Parser;

#[derive(Debug, Clone)]
pub struct Break<L: Lang> {
    inner: Box<Parser<L>>,
    break_: Box<Parser<L>>,
}

impl<L: Lang> Break<L> {
    pub fn parse(&self, state: &mut ParserState<L>, recover: bool) -> PRes {
        let index = state.push_delim(self.break_.as_ref().clone());
        let mut res = self.inner.do_parse(state, recover);
        if let PRes::Break(i) = res
            && index == i
        {
            res = PRes::Ok
        }
        state.pop_delim();
        res
    }

    pub fn peak(&self, state: &ParserState<L>, recover: bool, offset: usize) -> PRes {
        self.inner.peak(state, recover, offset)
    }

    pub fn expected(&self) -> Vec<Expected<L>> {
        self.inner.expected()
    }
}

impl<L: Lang> Parser<L> {
    pub fn break_at(self, parser: Parser<L>) -> Parser<L> {
        Parser::Break(Break {
            inner: Box::new(self),
            break_: Box::new(parser),
        })
    }
}
