use tracing::warn;

use crate::parser::{err::Expected, lang::Lang, res::PRes, state::ParserState};

use super::Parser;

#[derive(Clone)]
pub struct Fold<L: Lang> {
    name: L::Syntax,
    first: Box<Parser<L>>,
    next: Box<Parser<L>>,
}

impl<L: Lang> Fold<L> {
    pub fn parse(&self, state: &mut ParserState<L>) -> PRes {
        state.enter(self.name.clone());
        let first = self.first.do_parse(state);
        if first.is_err() {
            warn!("Disolving name");
            state.disolve_name();
            return first;
        }
        let mut count = 0;
        loop {
            let next = self.next.do_parse(state);
            if next.is_err() {
                if count == 0 {
                    warn!("Disolving name");
                    state.disolve_name();
                    return PRes::Ok;
                }
                break;
            }
            count += 1;
        }
        state.exit();
        PRes::Ok
    }

    pub fn peak(&self, state: &ParserState<L>) -> PRes {
        self.first.peak(state)
    }

    pub fn expected(&self) -> Vec<Expected<L>> {
        self.first.expected()
    }
}

impl<L: Lang> Parser<L> {
    pub fn fold(self, name: L::Syntax, next: Parser<L>) -> Parser<L> {
        Parser::Fold(Fold {
            name,
            first: Box::new(self),
            next: Box::new(next),
        })
    }
}
