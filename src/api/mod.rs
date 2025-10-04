use std::rc::Rc;

use choice::Choice;
use delim::Delim;
use fold::Fold;
use just::Just;
use named::Named;
use optional::Optional;
use rec::Recursive;
use recover::Recover;
use sep::Sep;
use seq::Seq;
use skip::Skip;
use tracing::debug;

use crate::{
    api::{
        break_::Break, custom::CustomParser, fold_once::FoldOnce, none_of::NoneOf, unskip::UnSkip,
    },
    parser::{err::Expected, lang::Lang, res::PRes, state::ParserState},
};

pub mod break_;
pub mod choice;
pub mod custom;
pub mod delim;
pub mod fold;
pub mod fold_once;
pub mod just;
pub mod maybe;
pub mod named;
pub mod none_of;
pub mod optional;
pub mod rec;
pub mod recover;
pub mod sep;
pub mod seq;
pub mod significant;
pub mod skip;
pub mod unskip;

#[derive(Debug, Clone)]
pub enum Parser<L: Lang> {
    Just(Just<L>),
    Custom(Rc<dyn CustomParser<L>>),
    Choice(Choice<L>),
    Seq(Seq<L>),
    Sep(Sep<L>),
    Delim(Delim<L>),
    Rec(Recursive<L>),
    Named(Named<L>),
    Fold(Fold<L>),
    Skip(Skip<L>),
    UnSkip(UnSkip<L>),
    Optional(Optional<L>),
    Recover(Recover<L>),
    NoneOf(NoneOf<L>),
    Break(Break<L>),
    FoldOnce(FoldOnce<L>),
}

impl<L: Lang> Parser<L> {
    pub fn do_parse(&self, state: &mut ParserState<L>, recover: bool) -> PRes {
        debug!("Parsing: {}", self.name());
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
            Parser::Optional(optional) => optional.parse(state, recover),
            Parser::Recover(r) => r.parse(state, recover),
            Parser::UnSkip(un_skip) => un_skip.parse(state, recover),
            Parser::NoneOf(none_of) => none_of.parse(state),
            Parser::Break(break_) => break_.parse(state, recover),
            Parser::Custom(custom_parser) => custom_parser.parse(state, recover),
            Parser::FoldOnce(fold_once) => fold_once.parse(state, recover),
        };
        debug!("Done parsing: {};{res:?}", self.name());
        res
    }

    pub fn peak(&self, state: &ParserState<L>, recover: bool, offset: usize) -> PRes {
        debug!("Peaking: {}", self.name());
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
            Parser::Optional(optional) => optional.peak(state, recover, offset),
            Parser::Recover(r) => r.peak(state, recover, offset),
            Parser::UnSkip(un_skip) => un_skip.peak(state, recover, offset),
            Parser::NoneOf(none_of) => none_of.peak(state, recover, offset),
            Parser::Break(break_) => break_.peak(state, recover, offset),
            Parser::Custom(custom_parser) => custom_parser.peak(state, recover, offset),
            Parser::FoldOnce(fold_once) => fold_once.peak(state, recover, offset),
        };
        debug!("Done peaking: {};{res:?}", self.name());
        res
    }

    pub fn expected(&self) -> Vec<Expected<L>> {
        debug!("Getting expected for {}", self.name());
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
            Parser::Optional(optional) => optional.expected(),
            Parser::Recover(r) => r.expected(),
            Parser::UnSkip(un_skip) => un_skip.expected(),
            Parser::NoneOf(none_of) => none_of.expected(),
            Parser::Break(break_) => break_.expected(),
            Parser::Custom(custom_parser) => custom_parser.expected(),
            Parser::FoldOnce(fold_once) => fold_once.expected(),
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
            Parser::Optional(_) => "Optional".to_string(),
            Parser::Recover(_) => "Recover".to_string(),
            Parser::UnSkip(_) => "Unskip".to_string(),
            Parser::NoneOf(_) => "NoneOf".to_string(),
            Parser::Break(_) => "Break".to_string(),
            Parser::Custom(custom_parser) => custom_parser.name(),
            Parser::FoldOnce(_) => "FoldOnce".to_string(),
        }
    }
}
