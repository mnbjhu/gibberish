use core::fmt;
use std::fmt::{Display, Formatter};

use crate::node::{Lexeme, Span};

use super::lang::Lang;

#[derive(Debug, PartialEq, Eq)]
pub enum ParseError<L: Lang> {
    MissingError {
        start: usize,
        expected: Vec<Expected<L>>,
    },
    Unexpected {
        start: usize,
        actual: Vec<Lexeme<L>>,
    },
}

impl<L: Lang> ParseError<L> {
    pub fn start(&self) -> usize {
        match self {
            ParseError::MissingError { start, .. } => *start,
            ParseError::Unexpected { start, .. } => *start,
        }
    }

    pub fn expected(&self) -> &[Expected<L>] {
        match self {
            ParseError::MissingError { expected, .. } => expected,
            ParseError::Unexpected { .. } => &[],
        }
    }

    pub fn actual(&self) -> &[Lexeme<L>] {
        match self {
            ParseError::MissingError { .. } => &[],
            ParseError::Unexpected { actual, .. } => actual,
        }
    }

    pub fn span(&self) -> Span {
        self.actual()
            .first()
            .map(|it| it.span.start..self.actual().last().unwrap().span.end)
            .unwrap_or(self.start()..self.start())
    }
}

#[derive(Debug, PartialEq, Eq)]
pub enum Expected<L: Lang> {
    Token(L::Token),
    Group(L::Syntax),
    Label(L::Syntax),
}

impl<L: Lang> Display for Expected<L> {
    fn fmt(&self, f: &mut Formatter<'_>) -> fmt::Result {
        match self {
            Expected::Token(t) => write!(f, "{t}"),
            Expected::Label(l) => write!(f, "{l}"),
            Expected::Group(g) => write!(f, "{g}"),
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
            self.expected().len(),
            "No value expected in error, maybe EOF"
        );
        let actual = self
            .actual()
            .iter()
            .map(|it| it.kind.to_string())
            .collect::<Vec<_>>()
            .join(",");

        if self.expected().len() == 1 {
            let expected = self.expected().first().unwrap();
            if self.actual().is_empty() {
                write!(f, "Missing {expected}")
            } else {
                write!(f, "Expected {expected} but found {actual}")
            }
        } else {
            let expected = self
                .expected()
                .iter()
                .map(|it| it.to_string())
                .collect::<Vec<_>>()
                .join(", ");
            if self.actual().is_empty() {
                write!(f, "Missing one of {expected}")
            } else {
                write!(f, "Expected one of {expected} but found {actual}")
            }
        }
    }
}

impl<L: Lang> Expected<L> {
    pub fn debug_name(&self, lang: &L) -> String {
        match self {
            Expected::Token(t) => lang.token_name(t),
            Expected::Label(_) => todo!(),
            Expected::Group(g) => lang.syntax_name(g),
        }
    }
}

impl<L: Lang> ParseError<L> {
    #[allow(dead_code)]
    fn fmt(&self, lang: &L) -> String {
        assert_ne!(
            0,
            self.expected().len(),
            "No value expected in error, maybe EOF"
        );
        let actual = self
            .actual()
            .iter()
            .map(|it| lang.token_name(&it.kind))
            .collect::<Vec<_>>()
            .join(",");

        if self.expected().len() == 1 {
            let expected = self.expected().first().unwrap();
            if self.actual().is_empty() {
                format!("Missing {expected}")
            } else {
                format!("Expected {expected} but found {actual}")
            }
        } else {
            let expected = self
                .expected()
                .iter()
                .map(|it| it.debug_name(lang))
                .collect::<Vec<_>>()
                .join(", ");
            if self.actual().is_empty() {
                format!("Missing one of {expected}")
            } else {
                format!("Expected one of {expected} but found {actual}")
            }
        }
    }
}
