use crate::{
    api::Parser,
    parser::{err::Expected, lang::Lang, res::PRes, state::ParserState},
};

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Optional<L: Lang>(Box<Parser<L>>);

impl<'a, L: Lang> Optional<L> {
    pub fn parse(&'a self, state: &mut ParserState<'a, L>, recover: bool) -> PRes {
        let res = self.0.peak(state, recover, state.after_skip());
        if res != PRes::Ok {
            return PRes::Ok;
        }
        self.0.do_parse(state, recover);
        res
    }

    pub fn peak(&'a self, state: &ParserState<'a, L>, recover: bool, offset: usize) -> PRes {
        let res = self.0.peak(state, recover, offset);
        if res == PRes::Err {
            return PRes::Ok;
        }
        res
    }

    pub fn expected(&self, state: &ParserState<'a, L>) -> Vec<Expected<L>> {
        self.0.expected(state)
    }
}

impl<L: Lang> Parser<L> {
    pub fn or_not(self) -> Parser<L> {
        Parser::Optional(Optional(Box::new(self)))
    }
}
