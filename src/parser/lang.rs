use super::node::Lexeme;

pub trait Lang: Clone + PartialEq + Eq {
    type Token: Clone + PartialEq + Eq;
    type Syntax;

    fn lex(src: &str) -> Vec<Lexeme<Self>>
    where
        Self: Sized;
}
