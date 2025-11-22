use std::fmt::Display;

use crate::node::{group_name, token_name};

#[derive(Debug)]
pub enum Expected {
    Token(usize),
    Group(usize),
    Label(usize),
}

#[repr(C)]
pub struct ExpectedData {
    kind: usize,
    id: usize,
}

impl From<ExpectedData> for Expected {
    fn from(value: ExpectedData) -> Self {
        match value.kind {
            0 => Expected::Token(value.id),
            1 => Expected::Group(value.id),
            2 => Expected::Label(value.id),
            kind => panic!("Unsupported kind for expected {kind}"),
        }
    }
}

impl Display for Expected {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let name: &str = unsafe {
            match self {
                Expected::Token(t) => token_name(*t as u32),
                Expected::Group(g) => group_name(*g as u32),
                Expected::Label(_) => todo!(),
            }
            .into()
        };
        write!(f, "{name}")
    }
}
