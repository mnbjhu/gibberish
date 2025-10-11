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
        let mut parsed_leading = false;
        let item_index = state.push_delim(self.item.clone());
        let sep_index = state.push_delim(self.sep.clone());
        if !matches!(self.leading, Requirement::No) {
            let leading = self
                .leading
                .parse(self.sep.get_ref(state.cache), state, recover);
            if leading != PRes::Ok {
                if matches!(self.leading, Requirement::Yes) {
                    state.pop_delim();
                    return leading;
                }
            } else {
                parsed_leading = true;
            }
        }
        let start = self.item.get_ref(state.cache).do_parse(state, recover);
        // TODO: Think about parsed leading and err case
        if start.is_err() && !parsed_leading {
            state.pop_delim();
            if self.at_least == 0 {
                return PRes::Ok;
            }
            return start;
        }
        let mut parsing_item = false;
        loop {
            let parser = if parsing_item { &self.item } else { &self.sep };
            let res = parser.get_ref(state.cache).do_parse(state, recover);
            match res {
                PRes::Ok => {
                    parsing_item = !parsing_item;
                }
                PRes::Err => {
                    state.bump_err(parser.get_ref(state.cache).expected(state));
                }
                PRes::Break(i) if i == sep_index => {
                    if parsing_item {
                        state.missing(self.item.get_ref(state.cache));
                        parsing_item = false;
                    } else {
                        state.bump_err(parser.get_ref(state.cache).expected(state));
                    }
                }
                PRes::Break(i) if i == item_index => {
                    if !parsing_item {
                        state.missing(self.sep.get_ref(state.cache));
                        parsing_item = true;
                    } else {
                        state.bump_err(parser.get_ref(state.cache).expected(state));
                    }
                }
                PRes::Break(_) | PRes::Eof => {
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
        PRes::Ok
    }

    pub fn peak(&'a self, state: &ParserState<'a, L>, recover: bool, offset: usize) -> PRes {
        let leading = self
            .leading
            .peak(self.sep.get_ref(state.cache), state, recover, offset);
        if leading != PRes::Ok {
            return leading;
        }
        self.item.get_ref(state.cache).peak(state, recover, offset)
    }

    pub fn expected(&self, state: &ParserState<'a, L>) -> Vec<Expected<L>> {
        match self.leading {
            Requirement::Yes => self.sep.get_ref(state.cache).expected(state),
            Requirement::No => self.item.get_ref(state.cache).expected(state),
            Requirement::Maybe => {
                let mut res = self.sep.get_ref(state.cache).expected(state);
                res.extend(self.item.get_ref(state.cache).expected(state));
                res
            }
        }
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
    ) -> Parser<L> {
        Parser::Sep(Sep {
            item: self,
            sep,
            leading,
            trailing,
            at_least: 0,
        })
    }
}
