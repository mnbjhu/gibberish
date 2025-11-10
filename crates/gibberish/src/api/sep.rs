use crate::{
    api::ptr::{ParserCache, ParserIndex},
    parser::{err::Expected, lang::Lang, res::PRes, state::ParserState},
};

use super::{Parser, maybe::Requirement};

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Sep<L: Lang> {
    sep: ParserIndex<L>,
    item: ParserIndex<L>,
    leading: Requirement,
    trailing: Requirement,
    at_least: usize,
}

impl<'a, L: Lang> Sep<L> {
    pub fn parse(&'a self, state: &mut ParserState<'a, L>, recover: bool) -> PRes {
        let item_index = state.push_delim(self.item.clone());
        let sep_index = state.push_delim(self.sep.clone());
        let (mut parsing_item, res) = self.leading.parse(
            self.sep.get_ref(state.cache),
            self.item.get_ref(state.cache),
            state,
            recover,
        );
        if !res.is_ok() {
            state.pop_delim();
            state.pop_delim();
            if self.at_least == 0 {
                return PRes::Ok;
            }
            return res;
        }
        loop {
            let parser = if parsing_item { &self.item } else { &self.sep };
            let res = parser.get_ref(state.cache).do_parse(state, recover);
            match res {
                PRes::Ok => {
                    parsing_item = !parsing_item;
                }
                PRes::Err => {
                    state.bump_err(parser.get_ref(state.cache).expected(state.cache));
                }
                PRes::Break(i) if i == sep_index => {
                    if parsing_item {
                        state.missing(self.item.get_ref(state.cache));
                        parsing_item = false;
                    } else {
                        panic!("Break for sep while parsing sep")
                    }
                }
                PRes::Break(i) if i == item_index => {
                    if !parsing_item {
                        state.missing(self.sep.get_ref(state.cache));
                        parsing_item = true;
                    } else {
                        panic!("Break for item while parsing item")
                    }
                }
                PRes::Break(_) | PRes::Eof => {
                    if let PRes::Break(index) = res {
                        assert!(index <= item_index)
                    }
                    if self.trailing == Requirement::Yes && !parsing_item {
                        state.missing(self.sep.get_ref(state.cache));
                    }
                    if self.trailing == Requirement::No && parsing_item {
                        state.missing(self.item.get_ref(state.cache));
                    }
                    break;
                }
            }
        }
        state.pop_delim();
        state.pop_delim();
        PRes::Ok
    }

    pub fn peak(&'a self, state: &ParserState<'a, L>, recover: bool, offset: usize) -> PRes {
        self.leading.peak(
            self.sep.get_ref(state.cache),
            self.item.get_ref(state.cache),
            state,
            recover,
            offset,
        )
    }

    pub fn expected(&self, cache: &ParserCache<L>) -> Vec<Expected<L>> {
        self.leading
            .expected(self.sep.get_ref(cache), self.item.get_ref(cache), cache)
    }
}

impl<L: Lang> ParserIndex<L> {
    pub fn sep_by(self, sep: ParserIndex<L>, cache: &mut ParserCache<L>) -> ParserIndex<L> {
        Parser::Sep(Sep {
            item: self,
            sep,
            leading: Requirement::No,
            trailing: Requirement::No,
            at_least: 0,
        })
        .cache(cache)
    }

    pub fn sep_by_extra(
        self,
        sep: ParserIndex<L>,
        leading: Requirement,
        trailing: Requirement,
        cache: &mut ParserCache<L>,
    ) -> ParserIndex<L> {
        Parser::Sep(Sep {
            item: self,
            sep,
            leading,
            trailing,
            at_least: 0,
        })
        .cache(cache)
    }
}
