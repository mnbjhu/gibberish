use tracing::warn;

use crate::parser::{err::Expected, lang::Lang, res::PRes, state::ParserState};

use super::Parser;

#[derive(Clone)]
pub struct Sep<L: Lang> {
    pub sep: Box<Parser<L>>,
    pub item: Box<Parser<L>>,
}

impl<L: Lang> Sep<L> {
    pub fn parse(&self, state: &mut ParserState<L>) -> PRes {
        let start = self.item.parse(state);
        if start.is_err() {
            return start;
        }
        state.push_delim(self.sep.as_ref().clone());
        loop {
            let sep = self.sep.parse(state);
            if sep.is_ok() {
                let item = self.item.parse(state);
                if !item.is_ok() {
                    warn!("Failed to parse item");
                    state.pop_delim();
                    return item;
                }
            } else {
                warn!("Failed to parse sep");
                break;
            }
        }
        state.pop_delim();
        PRes::Ok
    }

    pub fn peak(&self, state: &ParserState<L>) -> PRes {
        self.item.peak(state)
    }

    pub fn expected(&self) -> Vec<Expected<L>> {
        self.item.expected()
    }
}

impl<L: Lang> Parser<L> {
    pub fn sep_by(self, sep: Parser<L>) -> Parser<L> {
        Parser::Sep(Sep {
            item: Box::new(self),
            sep: Box::new(sep),
        })
    }
}
