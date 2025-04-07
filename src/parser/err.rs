use super::lang::Lang;

pub struct ParseError<L: Lang> {
    pub expected: Vec<Expected<L>>,
    pub actual: L::Token,
}

pub enum Expected<L: Lang> {
    Token(L::Syntax),
    Label(String),
}
