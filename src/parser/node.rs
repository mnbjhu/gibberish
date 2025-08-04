use std::ops::Range;

use super::lang::Lang;

pub type Span = Range<usize>;

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Lexeme<L: Lang> {
    pub span: Span,
    pub kind: L::Kind,
    pub text: String,
}
