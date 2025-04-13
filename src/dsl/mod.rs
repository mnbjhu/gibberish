use choice::Choice;
use delim::Delim;
use fold::Fold;
use just::Just;
use named::Named;
use rec::Recursive;
use sep::Sep;
use seq::Seq;
use tracing::info;

use crate::parser::{err::Expected, lang::Lang, res::PRes, state::ParserState};

pub mod choice;
pub mod delim;
pub mod fold;
pub mod just;
pub mod named;
pub mod no_skip;
pub mod rec;
pub mod sep;
pub mod seq;
pub mod skip;

#[derive(Clone)]
pub enum Parser<L: Lang> {
    Just(Just<L>),
    Choice(Choice<L>),
    Seq(Seq<L>),
    Sep(Sep<L>),
    Delim(Delim<L>),
    Rec(Recursive<L>),
    Named(Named<L>),
    Fold(Fold<L>),
    // Skip(Box<Parser<L>>),
    // NoSkip(Box<Parser<L>>),
}

impl<L: Lang> Parser<L> {
    pub fn parse(&self, state: &mut ParserState<L>) -> PRes {
        info!("Parsing: {}", self.name());
        let res = match self {
            Parser::Just(just) => just.parse(state),
            Parser::Choice(choice) => choice.parse(state),
            Parser::Seq(seq) => seq.parse(state),
            Parser::Sep(sep) => sep.parse(state),
            Parser::Delim(delim) => delim.parse(state),
            Parser::Rec(recursive) => recursive.parse(state),
            Parser::Named(named) => named.parse(state),
            Parser::Fold(fold) => fold.parse(state),
        };
        info!("Done parsing: {}", self.name());
        res
    }

    pub fn peak(&self, state: &ParserState<L>) -> PRes {
        info!("Peaking: {}", self.name());
        let res = match self {
            Parser::Just(just) => just.peak(state),
            Parser::Choice(choice) => choice.peak(state),
            Parser::Seq(seq) => seq.peak(state),
            Parser::Sep(sep) => sep.peak(state),
            Parser::Delim(delim) => delim.peak(state),
            Parser::Rec(recursive) => recursive.peak(state),
            Parser::Named(named) => named.peak(state),
            Parser::Fold(fold) => fold.peak(state),
        };
        info!("Done peaking: {}", self.name());
        res
    }

    pub fn expected(&self) -> Vec<Expected<L>> {
        match self {
            Parser::Just(just) => just.expected(),
            Parser::Choice(choice) => choice.expected(),
            Parser::Seq(seq) => seq.expected(),
            Parser::Sep(sep) => sep.expected(),
            Parser::Delim(delim) => delim.expected(),
            Parser::Rec(recursive) => recursive.expected(),
            Parser::Named(named) => named.expected(),
            Parser::Fold(fold) => fold.expected(),
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
        }
    }
}
