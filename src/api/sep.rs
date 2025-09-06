use tracing::warn;

use crate::parser::{err::Expected, lang::Lang, res::PRes, state::ParserState};

use super::{Parser, maybe::Requirement};

#[derive(Debug, Clone)]
pub struct Sep<L: Lang> {
    sep: Box<Parser<L>>,
    item: Box<Parser<L>>,
    leading: Requirement,
    trailing: Requirement,
}

impl<L: Lang> Sep<L> {
    pub fn parse(&self, state: &mut ParserState<L>, recover: bool) -> PRes {
        let mut parsed_leading = false;
        let index = state.push_delim(self.sep.as_ref().clone());
        if !matches!(self.leading, Requirement::No) {
            let leading = self.leading.parse(&self.sep, state, recover);
            if leading != PRes::Ok {
                if matches!(self.leading, Requirement::Yes) {
                    state.pop_delim();
                    return leading;
                }
            } else {
                parsed_leading = true;
            }
        }
        let start = self.item.do_parse(state, recover);
        // TODO: Think about parsed leading and err case
        if start.is_err() && !parsed_leading {
            state.pop_delim();
            return start;
        }
        let mut parsing_item = false;
        loop {
            let parser = if parsing_item { &self.item } else { &self.sep };
            let res = parser.do_parse(state, recover);
            match res {
                PRes::Ok => {
                    parsing_item = !parsing_item;
                }
                PRes::Err => {
                    state.bump_err(parser.expected());
                }
                PRes::Break(i) if i == index => {
                    if parsing_item {
                        state.missing(&self.item);
                        parsing_item = false;
                    } else {
                        state.bump_err(parser.expected());
                    }
                }
                PRes::Break(_) | PRes::Eof => {
                    if self.trailing == Requirement::Yes && !parsing_item {
                        state.missing(&self.item);
                    }
                    if self.trailing == Requirement::No && parsing_item {
                        state.missing(&self.sep);
                    }
                    break;
                }
            }
        }
        state.pop_delim();
        PRes::Ok
    }

    pub fn peak(&self, state: &ParserState<L>, recover: bool, offset: usize) -> PRes {
        let leading = self.leading.peak(&self.sep, state, recover, offset);
        if leading != PRes::Ok {
            return leading;
        }
        self.item.peak(state, recover, offset)
    }

    pub fn expected(&self) -> Vec<Expected<L>> {
        match self.leading {
            Requirement::Yes => self.sep.expected(),
            Requirement::No => self.item.expected(),
            Requirement::Maybe => {
                let mut res = self.sep.expected();
                res.extend(self.item.expected());
                res
            }
        }
    }
}

impl<L: Lang> Parser<L> {
    pub fn sep_by(self, sep: Parser<L>) -> Parser<L> {
        Parser::Sep(Sep {
            item: Box::new(self),
            sep: Box::new(sep),
            leading: Requirement::No,
            trailing: Requirement::No,
        })
    }

    pub fn sep_by_extra(
        self,
        sep: Parser<L>,
        leading: Requirement,
        trailing: Requirement,
    ) -> Parser<L> {
        Parser::Sep(Sep {
            item: Box::new(self),
            sep: Box::new(sep),
            leading,
            trailing,
        })
    }
}
