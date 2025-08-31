use crate::{
    api::Parser,
    parser::{err::Expected, lang::Lang, res::PRes, state::ParserState},
};

#[derive(Debug, Clone)]
pub struct Optional<L: Lang>(Box<Parser<L>>);

impl<L: Lang> Optional<L> {
    pub fn parse(&self, state: &mut ParserState<L>, recover: bool) -> PRes {
        let res = self.0.peak(state, recover, state.after_skip());
        if res != PRes::Ok {
            return PRes::Ok;
        }
        self.0.do_parse(state, recover);
        res
    }

    pub fn peak(&self, state: &ParserState<L>, recover: bool, offset: usize) -> PRes {
        let res = self.0.peak(state, recover, offset);
        if res == PRes::Err {
            return PRes::Ok;
        }
        res
    }

    pub fn expected(&self) -> Vec<Expected<L>> {
        self.0.expected()
    }
}

impl<L: Lang> Parser<L> {
    pub fn or_not(self) -> Parser<L> {
        Parser::Optional(Optional(Box::new(self)))
    }
}
