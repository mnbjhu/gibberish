use crate::parser::{err::Expected, lang::Lang, res::PRes, state::ParserState};

use super::Parser;

#[derive(Debug, Clone)]
pub struct Skip<L: Lang> {
    token: L::Token,
    inner: Box<Parser<L>>,
}

impl<L: Lang> Skip<L> {
    pub fn parse(&self, state: &mut ParserState<L>, recover: bool) -> PRes {
        let added = state.skip(self.token.clone());
        let res = self.inner.do_parse(state, recover);
        if added {
            state.unskip(self.token.clone());
        }
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
    pub fn skip(self, token: L::Token) -> Parser<L> {
        Parser::Skip(Skip {
            token,
            inner: Box::new(self),
        })
    }
}
