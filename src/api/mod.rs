use choice::Choice;
use delim::Delim;
use fold::Fold;
use just::Just;
use named::Named;
use rec::Recursive;
use sep::Sep;
use seq::Seq;
use skip::Skip;
use tracing::info;

use crate::parser::{err::Expected, lang::Lang, res::PRes, state::ParserState};

pub mod choice;
pub mod delim;
pub mod fold;
pub mod just;
pub mod maybe;
pub mod named;
pub mod rec;
pub mod sep;
pub mod seq;
pub mod significant;
pub mod skip;

#[derive(Debug, Clone)]
pub enum Parser<L: Lang> {
    Just(Just<L>),
    Choice(Choice<L>),
    Seq(Seq<L>),
    Sep(Sep<L>),
    Delim(Delim<L>),
    Rec(Recursive<L>),
    Named(Named<L>),
    Fold(Fold<L>),
    Skip(Skip<L>),
}

impl<L: Lang> Parser<L> {
    pub fn do_parse(&self, state: &mut ParserState<L>, recover: bool) -> PRes {
        info!("Parsing: {}", self.name());
        let res = match self {
            Parser::Just(just) => just.parse(state),
            Parser::Choice(choice) => choice.parse(state, recover),
            Parser::Seq(seq) => seq.parse(state, recover),
            Parser::Sep(sep) => sep.parse(state, recover),
            Parser::Delim(delim) => delim.parse(state, recover),
            Parser::Rec(recursive) => recursive.parse(state, recover),
            Parser::Named(named) => named.parse(state, recover),
            Parser::Fold(fold) => fold.parse(state, recover),
            Parser::Skip(skip) => skip.parse(state, recover),
        };
        info!("Done parsing: {};{res:?}", self.name());
        res
    }

    pub fn peak(&self, state: &ParserState<L>, recover: bool, offset: usize) -> PRes {
        info!("Peaking: {}", self.name());
        let res = match self {
            Parser::Just(just) => just.peak(state, recover, offset),
            Parser::Choice(choice) => choice.peak(state, recover, offset),
            Parser::Seq(seq) => seq.peak(state, recover, offset),
            Parser::Sep(sep) => sep.peak(state, recover, offset),
            Parser::Delim(delim) => delim.peak(state, recover, offset),
            Parser::Rec(recursive) => recursive.peak(state, recover, offset),
            Parser::Named(named) => named.peak(state, recover, offset),
            Parser::Fold(fold) => fold.peak(state, recover, offset),
            Parser::Skip(skip) => skip.peak(state, recover, offset),
        };
        info!("Done peaking: {};{res:?}", self.name());
        res
    }

    pub fn expected(&self) -> Vec<Expected<L>> {
        info!("Getting expected for {}", self.name());
        match self {
            Parser::Just(just) => just.expected(),
            Parser::Choice(choice) => choice.expected(),
            Parser::Seq(seq) => seq.expected(),
            Parser::Sep(sep) => sep.expected(),
            Parser::Delim(delim) => delim.expected(),
            Parser::Rec(recursive) => recursive.expected(),
            Parser::Named(named) => named.expected(),
            Parser::Fold(fold) => fold.expected(),
            Parser::Skip(skip) => skip.expected(),
        }
    }

    pub fn name(&self) -> String {
        match self {
            Parser::Just(just) => just.to_string(),
            Parser::Choice(_) => "Choice".to_string(),
            Parser::Seq(_) => "Seq".to_string(),
            Parser::Sep(_) => "Sep".to_string(),
            Parser::Delim(_) => "Delim".to_string(),
            Parser::Rec(_) => "Rec".to_string(),
            Parser::Named(named) => named.to_string(),
            Parser::Fold(_) => "Fold".to_string(),
            Parser::Skip(_) => "Skip".to_string(),
        }
    }
}
