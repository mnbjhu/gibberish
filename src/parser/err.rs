use core::fmt;
use std::fmt::{Display, Formatter};

use crate::parser::node::Lexeme;

use super::lang::Lang;

#[derive(Debug, PartialEq, Eq)]
pub struct ParseError<L: Lang> {
    pub start: usize,
    pub expected: Vec<Expected<L>>,
    pub actual: Vec<Lexeme<L>>,
}

#[derive(Debug, PartialEq, Eq)]
pub enum Expected<L: Lang> {
    Token(L::Token),
    Label(L::Syntax),
}

impl<L: Lang> Display for Expected<L> {
    fn fmt(&self, f: &mut Formatter<'_>) -> fmt::Result {
        match self {
            Expected::Token(t) => write!(f, "{t}"),
            Expected::Label(l) => write!(f, "{l}"),
        }
    }
}

impl<L: Lang> Display for ParseError<L>
where
    L::Token: Display,
    L::Syntax: Display,
{
    fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
        assert_ne!(
            0,
            self.expected.len(),
            "No value expected in error, maybe EOF"
        );
        let actual = self
            .actual
            .iter()
            .map(|it| it.kind.to_string())
            .collect::<Vec<_>>()
            .join(",");

        if self.expected.len() == 1 {
            let expected = self.expected.first().unwrap();
            if self.actual.is_empty() {
                write!(f, "Missing {expected}")
            } else {
                write!(f, "Expected {expected} but found {actual}")
            }
        } else {
            let expected = self
                .expected
                .iter()
                .map(|it| it.to_string())
                .collect::<Vec<_>>()
                .join(", ");
            if self.actual.is_empty() {
                write!(f, "Missing one of {expected}")
            } else {
                write!(f, "Expected one of {expected} but found {actual}")
            }
        }
    }
}
