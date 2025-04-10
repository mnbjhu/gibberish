use std::ops::Range;

use super::{err::ParseError, lang::Lang};

pub type Span = Range<usize>;

#[derive(Clone, PartialEq, Eq)]
pub struct Lexeme<L: Lang> {
    pub span: Span,
    pub kind: L::Token,
}

pub enum Node<L: Lang> {
    Group {
        kind: L::Syntax,
        errors: Vec<ParseError<L>>,
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

    pub fn push_err(&mut self, error: ParseError<L>) {
        match self {
            Node::Group { errors, .. } => errors.push(error),
            Node::Lexeme(_) => panic!("Cannot push error to a lexeme"),
        }
    }

    fn debug_at(&self, offset: usize) {
        for _ in 0..offset {
            print!("  ");
        }
        match self {
            Node::Group {
                kind,
                children,
                errors,
            } => {
                println!("{kind}");
                for error in errors {
                    for _ in 0..offset + 1 {
                        print!("  ");
                    }
                    println!("@{error}")
                }
                for child in children {
                    child.debug_at(offset + 1);
                }
            }
            Node::Lexeme(lexeme) => {
                println!("{}", lexeme.kind)
            }
        }
    }

    pub fn debug_print(&self) {
        self.debug_at(0);
    }
}
