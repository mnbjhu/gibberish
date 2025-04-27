use std::ops::Range;

use super::{
    err::{Expected, ParseError},
    lang::Lang,
};
use ansi_term::Colour::{Blue, Green, Red};

pub type Span = Range<usize>;

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Lexeme<L: Lang> {
    pub span: Span,
    pub kind: L::Token,
}

#[derive(Debug)]
pub struct Group<L: Lang> {
    pub kind: L::Syntax,
    pub children: Vec<Node<L>>,
}

#[derive(Debug)]
pub struct ErrGroup<L: Lang> {
    pub err: Vec<Expected<L>>,
    pub children: Vec<L::Token>,
}

#[derive(Debug)]
pub enum Node<L: Lang> {
    Group(Group<L>),
    Lexeme(Lexeme<L>),
    Err(ParseError<L>),
}

impl<L: Lang> Node<L> {
    pub fn push_tok(&mut self, lexeme: Lexeme<L>) {
        let Node::Group(Group { children, .. }) = self else {
            panic!("Expected a group")
        };
        children.push(Node::Lexeme(lexeme))
    }

    fn debug_at(&self, offset: usize, errors: bool, tokens: bool) {
        fn print_offset(n: usize) {
            for _ in 0..n {
                print!("  ");
            }
        }
        match self {
            Node::Group(Group { kind, children }) => {
                print_offset(offset);
                println!("{}", Green.paint(kind.to_string()));
                for child in children {
                    child.debug_at(offset + 1, errors, tokens);
                }
            }
            Node::Lexeme(lexeme) => {
                if tokens {
                    print_offset(offset);
                    println!("{}", Blue.paint(lexeme.kind.to_string()))
                }
            }
            Node::Err(err_group) => {
                if errors {
                    print_offset(offset);
                    err_group.debug_at(offset)
                }
            }
        }
    }

    pub fn debug_print(&self, errors: bool, tokens: bool) {
        self.debug_at(0, errors, tokens);
    }

    pub fn name(&self) -> L::Syntax {
        match self {
            Node::Group(Group { kind, .. }) => kind.clone(),
            Node::Lexeme(_) => panic!("Lexeme has no name"),
            Node::Err(_) => panic!("ErrGroup has no name"),
        }
    }

    pub fn green_children(&self) -> impl Iterator<Item = &Group<L>> {
        match self {
            Node::Group(Group { children, .. }) => children.iter().filter_map(|it| match it {
                Node::Group(group) => Some(group),
                Node::Lexeme(_) => None,
                Node::Err(_) => None,
            }),
            Node::Lexeme(_) => panic!("Lexeme has no children"),
            Node::Err(_) => panic!("ErrGroup has no children"),
        }
    }

    pub fn is_okay(&self) -> bool {
        match self {
            Node::Group(group) => group.is_okay(),
            Node::Lexeme(_) => true,
            Node::Err(_) => false,
        }
    }

    // TODO: Think about empty groups/errors
    pub fn start(&self) -> usize {
        match self {
            Node::Group(group) => group.start(),
            Node::Lexeme(lexeme) => lexeme.span.start,
            Node::Err(_) => todo!(),
        }
    }

    // TODO: Think about empty groups/errors
    pub fn end(&self) -> usize {
        match self {
            Node::Group(group) => group.end(),
            Node::Lexeme(lexeme) => lexeme.span.end,
            Node::Err(_) => todo!(),
        }
    }

    pub fn span(&self) -> Range<usize> {
        self.start()..self.end()
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
            Node::Err(_) => None,
        })
    }

    pub fn errors(&self) -> impl Iterator<Item = &ParseError<L>> {
        self.children.iter().filter_map(|it| match it {
            Node::Err(e) => Some(e),
            _ => None,
        })
    }

    pub fn is_okay(&self) -> bool {
        self.children.iter().all(|it| it.is_okay())
    }
    
    pub fn child_by_name(&self, name: &L::Syntax) -> Option<&Group<L>> {
        self.children.iter().find_map(|it| match it {
            Node::Group(group) => if &group.kind == name {
                Some(group)
            } else {
                None
            },
            _ => None
        })
    }

    pub fn start(&self) -> usize {
        self.children.first().expect("Can't get start of empty group").start()
    }
    pub fn end(&self) -> usize {
        self.children.last().expect("Can't get end of empty group").end()
    }

    pub fn span(&self) -> Range<usize>{
        self.start()..self.end()
    }
}

impl<L: Lang> ParseError<L> {
    fn debug_at(&self, offset: usize) {
        // NOTE: Only works when called by outer 'debug_at'
        let expected = self
            .expected
            .iter()
            .map(|it| it.to_string())
            .collect::<Vec<_>>()
            .join(",");
        println!("Expected: {expected}");
        for token in &self.actual {
            for _ in 0..offset {
                print!("  ");
            }
            println!("  {}", Red.paint(token.kind.to_string()));
        }
    }
}
