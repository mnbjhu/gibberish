use choice::Choice;
use delim::Delim;
use gibberish_core::{err::Expected, lang::CompiledLang};
use just::Just;
use named::Named;
use optional::Optional;
use sep::Sep;
use seq::Seq;
use skip::Skip;
use tracing::debug;

use crate::api::{fold_once::FoldOnce, ptr::ParserCache, repeated::Repeated, unskip::UnSkip};

pub mod choice;
pub mod delim;
pub mod fold_once;
pub mod just;
pub mod named;
pub mod optional;
pub mod ptr;
pub mod repeated;
pub mod sep;
pub mod seq;
pub mod skip;
pub mod unskip;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub enum Parser {
    Just(Just),
    Choice(Choice),
    Seq(Seq),
    Sep(Sep),
    Delim(Delim),
    Named(Named),
    Skip(Skip),
    UnSkip(UnSkip),
    Optional(Optional),
    FoldOnce(FoldOnce),
    Repeated(Repeated),
    Empty,
}

impl<'a> Parser {
    pub fn expected(&self, cache: &ParserCache) -> Vec<Expected<CompiledLang>> {
        debug!("Getting expected for {}", self.name());
        match self {
            Parser::Just(just) => just.expected(),
            Parser::Choice(choice) => choice.expected(cache),
            Parser::Seq(seq) => seq.expected(cache),
            Parser::Sep(sep) => sep.expected(cache),
            Parser::Delim(delim) => delim.expected(cache),
            Parser::Named(named) => named.expected(),
            Parser::Skip(skip) => skip.expected(cache),
            Parser::Optional(optional) => optional.expected(cache),
            Parser::UnSkip(un_skip) => un_skip.expected(cache),
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
            Parser::Named(named) => named.to_string(),
            Parser::Skip(_) => "Skip".to_string(),
            Parser::Optional(_) => "Optional".to_string(),
            Parser::UnSkip(_) => "Unskip".to_string(),
            Parser::FoldOnce(_) => "FoldOnce".to_string(),
            Parser::Empty => todo!(),
            Parser::Repeated(_) => "Repeated".to_string(),
        }
    }
}
