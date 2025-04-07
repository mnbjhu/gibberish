use std::rc::Rc;

use delim::Delim;
use just::Just;

use crate::parser::{lang::Lang, res::PRes, state::ParserState};

pub mod choice;
pub mod delim;
pub mod just;
pub mod no_skip;
pub mod rec;
pub mod sep;
pub mod seq;
pub mod skip;

#[derive(Clone)]
pub enum Parser<L: Lang> {
    Just(Just<L>),
    Choice(Vec<Parser<L>>),
    Seq(Vec<Parser<L>>),
    Sep(Vec<Parser<L>>),
    Delim(Delim<L>),
    Skip(Box<Parser<L>>),
    NoSkip(Box<Parser<L>>),
    Rec(Rc<Parser<L>>),
}

impl<L: Lang> Parser<L> {
    pub fn parse(&self, state: &mut ParserState<L>) -> PRes {}
    pub fn peak(&self, state: &ParserState<L>) -> PRes {}
}
