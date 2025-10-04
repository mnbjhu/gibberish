use crate::parser::{err::Expected, lang::Lang, res::PRes, state::ParserState};

use super::Parser;

#[derive(Debug, Clone)]
pub struct FoldOnce<L: Lang> {
    name: L::Syntax,
    first: Box<Parser<L>>,
    next: Box<Parser<L>>,
}

impl<L: Lang> FoldOnce<L> {
    pub fn parse(&self, state: &mut ParserState<L>, recover: bool) -> PRes {
        state.enter(self.name.clone());
        let first = self.first.do_parse(state, recover);
        if first.is_err() {
            state.disolve_name();
            return first;
        }
        if self.next.peak(state, recover, state.after_skip()).is_err() {
            state.disolve_name();
            return PRes::Ok;
        } else {
            self.next.do_parse(state, recover);
        }
        state.exit();
        PRes::Ok
    }

    pub fn peak(&self, state: &ParserState<L>, recover: bool, offset: usize) -> PRes {
        self.first.peak(state, recover, offset)
    }

    pub fn expected(&self) -> Vec<Expected<L>> {
        self.first.expected()
    }
}

impl<L: Lang> Parser<L> {
    pub fn fold_once(self, name: L::Syntax, next: Parser<L>) -> Parser<L> {
        Parser::FoldOnce(FoldOnce {
            name,
            first: Box::new(self),
            next: Box::new(next),
        })
    }
}
