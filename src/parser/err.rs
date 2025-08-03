use core::fmt;
use std::fmt::{Display, Formatter};

use super::lang::Lang;

#[derive(Debug, PartialEq, Eq)]
pub struct ParseError<L: Lang> {
    pub expected: Vec<Expected<L>>,
    pub actual: Vec<L::Kind>,
}

#[derive(Debug, PartialEq, Eq)]
pub enum Expected<L: Lang> {
    Token(L::Kind),
}

impl<L: Lang> Display for Expected<L>
where
    L::Kind: Display,
{
    fn fmt(&self, f: &mut Formatter<'_>) -> fmt::Result {
        match self {
            Expected::Token(t) => write!(f, "{t}"),
        }
    }
}

impl<L: Lang> Display for ParseError<L>
where
    L::Kind: Display,
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
            .map(|it| it.to_string())
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
