use crate::{
    api::{Parser, ptr::ParserCache},
    parser::{err::Expected, lang::Lang, res::PRes, state::ParserState},
};

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Recover<L: Lang> {
    try_: Box<Parser<L>>,
    otherwise: Box<Parser<L>>,
}

impl<'a, L: Lang> Recover<L> {
    pub fn parse(&'a self, state: &mut ParserState<'a, L>, recover: bool) -> PRes {
        let res = self.try_.do_parse(state, recover);
        if res != PRes::Ok {
            state.missing(&self.try_);
            self.otherwise.do_parse(state, recover)
        } else {
            res
        }
    }

    pub fn peak(&'a self, state: &ParserState<'a, L>, recover: bool, offset: usize) -> PRes {
        let res = self.try_.peak(state, recover, offset);
        if res != PRes::Ok {
            self.otherwise.peak(state, recover, offset)
        } else {
            res
        }
    }

    pub fn expected(&self, state: &ParserCache<L>) -> Vec<Expected<L>> {
        self.try_.expected(state)
    }
}

impl<L: Lang> Parser<L> {
    pub fn recover_with(self, otherwise: Parser<L>) -> Parser<L> {
        Parser::Recover(Recover {
            try_: Box::new(self),
            otherwise: Box::new(otherwise),
        })
    }
}
