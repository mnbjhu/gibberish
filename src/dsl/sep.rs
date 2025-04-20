use tracing::warn;

use crate::parser::{err::Expected, lang::Lang, res::PRes, state::ParserState};

use super::Parser;

#[derive(Debug, Clone)]
pub struct Sep<L: Lang> {
    sep: Box<Parser<L>>,
    item: Box<Parser<L>>,
}

impl<L: Lang> Sep<L> {
    pub fn parse(&self, state: &mut ParserState<L>, recover: bool) -> PRes {
        let start = self.item.do_parse(state, recover);
        if start.is_err() {
            return start;
        }
        let index = state.push_delim(self.sep.as_ref().clone());
        loop {
            let sep = state.try_parse(&self.sep, recover);
            if sep.is_ok() {
                let item = state.try_parse(&self.item, recover);
                if item == PRes::Break(index) {
                    state.missing(&self.item);
                    continue;
                } else if matches!(item, PRes::Break(_)) {
                    state.pop_delim();
                    state.missing(&self.item);
                    return PRes::Ok;
                }
                if item.is_err() {
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

    pub fn peak(&self, state: &ParserState<L>, recover: bool) -> PRes {
        self.item.peak(state, recover)
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
