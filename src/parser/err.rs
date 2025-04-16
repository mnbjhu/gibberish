use core::fmt;
use std::fmt::{Display, Formatter};

use super::lang::Lang;

#[derive(Debug)]
pub struct ParseError<L: Lang> {
    pub expected: Vec<Expected<L>>,
    pub actual: Vec<Option<L::Token>>,
}

#[derive(Debug)]
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
            .map(|it| {
                it.as_ref()
                    .map(|tok| tok.to_string())
                    .unwrap_or("eof".to_string())
            })
            .collect::<Vec<_>>()
            .join("");
        if self.expected.len() == 1 {
            let expected = self.expected.first().unwrap();
            write!(f, "Expected {expected} but found {actual}")
        } else {
            let expected = self
                .expected
                .iter()
                .map(|it| it.to_string())
                .collect::<Vec<_>>()
                .join(", ");
            write!(f, "Expected one of {expected} but found {actual}")
        }
    }
}
