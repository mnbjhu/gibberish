use std::ops::Range;

use super::{err::ParseError, lang::Lang};

pub type Span = Range<usize>;

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Lexeme<L: Lang> {
    pub span: Span,
    pub kind: L::Token,
}

#[derive(Debug)]
pub struct Group<L: Lang> {
    pub kind: L::Syntax,
    pub errors: Vec<ParseError<L>>,
    pub children: Vec<Node<L>>,
}

#[derive(Debug)]
pub enum Node<L: Lang> {
    Group(Group<L>),
    Lexeme(Lexeme<L>),
}

impl<L: Lang> Node<L> {
    pub fn push_tok(&mut self, lexeme: Lexeme<L>) {
        match self {
            Node::Group(Group { children, .. }) => children.push(Node::Lexeme(lexeme)),
            Node::Lexeme(_) => panic!("Cannot push token to a lexeme"),
        }
    }

    pub fn push_err(&mut self, error: ParseError<L>) {
        match self {
            Node::Group(Group { errors, .. }) => errors.push(error),
            Node::Lexeme(_) => panic!("Cannot push error to a lexeme"),
        }
    }

    fn debug_at(&self, offset: usize) {
        for _ in 0..offset {
            print!("  ");
        }
        match self {
            Node::Group(Group {
                kind,
                children,
                errors,
            }) => {
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

    pub fn name(&self) -> L::Syntax {
        match self {
            Node::Group(Group { kind, .. }) => kind.clone(),
            Node::Lexeme(_) => panic!("Lexeme has no name"),
        }
    }

    pub fn green_children(&self) -> impl Iterator<Item = &Group<L>> {
        match self {
            Node::Group(Group { children, .. }) => children.iter().filter_map(|it| match it {
                Node::Group(group) => Some(group),
                Node::Lexeme(_) => None,
            }),
            Node::Lexeme(_) => panic!("Lexeme has no children"),
        }
    }
}

impl<L: Lang> Group<L> {
    pub fn name(&self) -> L::Syntax {
        self.kind.clone()
    }

    pub fn green_children(&self) -> impl Iterator<Item = &Group<L>> {
        self.children.iter().filter_map(|it| match it {
            Node::Group(group) => Some(group),
            Node::Lexeme(_) => None,
        })
    }
}
