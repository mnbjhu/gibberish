use gibberish_core::{err::Expected, lang::Lang};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct NoneOf<L: Lang>(Vec<L::Token>);

impl<L: Lang> NoneOf<L> {
    pub fn expected(&self) -> Vec<Expected<L>> {
        vec![] // TODO: Think about expected here
    }
}

pub fn none_of<L: Lang>(toks: Vec<L::Token>) -> Parser<L> {
    Parser::NoneOf(NoneOf(toks))
}
