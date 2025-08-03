use std::ops::Range;

use super::{
    err::{Expected, ParseError},
    lang::Lang,
};
use ansi_term::Colour::{Blue, Green, Red};

pub type Span = Range<usize>;

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Lexeme<L: Lang> {
    pub span: Span,
    pub kind: L::Kind,
    pub text: String,
}
