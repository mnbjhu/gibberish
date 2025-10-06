use crate::{
    api::ptr::{ParserCache, ParserIndex},
    parser::{err::Expected, lang::Lang, res::PRes, state::ParserState},
};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Choice<L: Lang> {
    options: Vec<ParserIndex<L>>,
}

impl<'a, L: Lang> Choice<L> {
    pub fn parse(&'a self, state: &mut ParserState<'a, L>, recover: bool) -> PRes {
        let mut res = self.options[0]
            .get_ref(state.cache)
            .peak(state, recover, state.after_skip());
        if res.is_ok() {
            return self.options[0]
                .get_ref(state.cache)
                .do_parse(state, recover);
        }
        for option in &self.options[1..] {
            res = option
                .get_ref(state.cache)
                .peak(state, recover, state.after_skip());
            if res.is_ok() {
                return option.get_ref(state.cache).do_parse(state, recover);
            }
        }
        res
    }

    pub fn peak(&self, state: &ParserState<L>, recover: bool, offset: usize) -> PRes {
        for p in &self.options {
            let res = p.get_ref(state.cache).peak(state, recover, offset);
            if res.is_ok() {
                return PRes::Ok;
            } else if matches!(res, PRes::Break(_) | PRes::Eof) {
                return res;
            }
        }
        PRes::Err
    }

    pub fn expected(&self, state: &ParserState<'a, L>) -> Vec<Expected<L>> {
        self.options
            .iter()
            .flat_map(|it| it.get_ref(state.cache).expected(state))
            .collect()
    }
}

pub fn choice<L: Lang>(options: Vec<ParserIndex<L>>, cache: &mut ParserCache<L>) -> ParserIndex<L> {
    Parser::Choice(Choice { options }).cache(cache)
}

impl<L: Lang> ParserIndex<L> {
    pub fn or(self, other: ParserIndex<L>, cache: &mut ParserCache<L>) -> ParserIndex<L> {
        if let Parser::Choice(options) = self.get_mut(cache) {
            options.options.push(other);
            self
        } else {
            choice(vec![self, other], cache)
        }
    }
}
