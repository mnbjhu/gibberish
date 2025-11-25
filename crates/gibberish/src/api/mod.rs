use choice::Choice;
use delim::Delim;
use fold::Fold;
use gibberish_tree::{err::Expected, lang::Lang};
use just::Just;
use named::Named;
use optional::Optional;
use rec::Recursive;
use sep::Sep;
use seq::Seq;
use skip::Skip;
use tracing::debug;

use crate::api::{
    break_::Break, fold_once::FoldOnce, none_of::NoneOf, ptr::ParserCache, repeated::Repeated,
    unskip::UnSkip,
};

pub mod break_;
pub mod choice;
pub mod delim;
pub mod fold;
pub mod fold_once;
pub mod just;
pub mod maybe;
pub mod named;
pub mod none_of;
pub mod optional;
pub mod ptr;
pub mod rec;
pub mod repeated;
pub mod sep;
pub mod seq;
pub mod significant;
pub mod skip;
pub mod unskip;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub enum Parser<L: Lang> {
    Just(Just<L>),
    // Custom(Rc<dyn CustomParser<L>>),
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
    NoneOf(NoneOf<L>),
    Break(Break<L>),
    FoldOnce(FoldOnce<L>),
    Repeated(Repeated<L>),
    Empty,
}

impl<'a, L: Lang> Parser<L> {
    pub fn expected(&self, cache: &ParserCache<L>) -> Vec<Expected<L>> {
        debug!("Getting expected for {}", self.name());
        match self {
            Parser::Just(just) => just.expected(),
            Parser::Choice(choice) => choice.expected(cache),
            Parser::Seq(seq) => seq.expected(cache),
            Parser::Sep(sep) => sep.expected(cache),
            Parser::Delim(delim) => delim.expected(cache),
            Parser::Rec(recursive) => recursive.expected(cache),
            Parser::Named(named) => named.expected(),
            Parser::Fold(fold) => fold.expected(cache),
            Parser::Skip(skip) => skip.expected(cache),
            Parser::Optional(optional) => optional.expected(cache),
            Parser::UnSkip(un_skip) => un_skip.expected(cache),
            Parser::NoneOf(none_of) => none_of.expected(),
            Parser::Break(break_) => break_.expected(cache),
            Parser::FoldOnce(fold_once) => fold_once.expected(cache),
            Parser::Empty => todo!(),
            Parser::Repeated(repeated) => repeated.expected(cache),
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
            Parser::UnSkip(_) => "Unskip".to_string(),
            Parser::NoneOf(_) => "NoneOf".to_string(),
            Parser::Break(_) => "Break".to_string(),
            Parser::FoldOnce(_) => "FoldOnce".to_string(),
            Parser::Empty => todo!(),
            Parser::Repeated(_) => "Repeated".to_string(),
        }
    }
}
