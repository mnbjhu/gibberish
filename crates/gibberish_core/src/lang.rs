use std::fmt::{Debug, Display};
use std::hash::Hash;

pub trait Lang: PartialEq + Eq + Display + Debug + Hash + Clone {
    type Token: Clone + PartialEq + Eq + Display + Debug + Hash;
    type Syntax: Clone + PartialEq + Eq + Display + Debug + Hash;
    type Label: Clone + PartialEq + Eq + Display + Debug + Hash;

    fn token_name(&self, token: &Self::Token) -> String {
        format!("{token}")
    }

    fn syntax_name(&self, syntax: &Self::Syntax) -> String {
        format!("{syntax}")
    }

    fn label_name(&self, label: &Self::Label) -> String {
        format!("{label}")
    }
}

#[derive(Debug, PartialEq, Eq, Clone, Copy, Hash)]
pub struct RawLang;

impl Display for RawLang {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "CompiledLang")
    }
}

impl Lang for RawLang {
    type Token = u32;
    type Syntax = u32;
    type Label = u32;
}
