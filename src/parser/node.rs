use std::ops::Range;

use super::lang::Lang;

pub type Span = Range<usize>;

#[derive(Clone, PartialEq, Eq)]
pub struct Lexeme<L: Lang> {
    pub span: Span,
    pub kind: L::Token,
}

pub enum Node<L: Lang> {
    Group {
        kind: L::Syntax,
        errors: Vec<String>,
        children: Vec<Node<L>>,
    },
    Lexeme(Lexeme<L>),
}

impl<L: Lang> Node<L> {
    pub fn push_tok(&mut self, lexeme: Lexeme<L>) {
        match self {
            Node::Group { children, .. } => children.push(Node::Lexeme(lexeme)),
            Node::Lexeme(_) => panic!("Cannot push token to a lexeme"),
        }
    }
}
