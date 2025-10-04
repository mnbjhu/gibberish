use std::{
    fmt::{Debug, Display, write},
    ops::Range,
};

use super::{err::ParseError, lang::Lang};
use ansi_term::Colour::{Blue, Green, Red};

pub type Span = Range<usize>;

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Lexeme<L: Lang> {
    pub span: Span,
    pub kind: L::Token,
    pub text: String,
}

#[derive(Debug)]
pub struct Group<L: Lang> {
    pub kind: L::Syntax,
    pub children: Vec<Node<L>>,
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

    pub fn as_group(&self) -> &Group<L> {
        let Node::Group(group) = self else {
            panic!("Expected a group");
        };
        group
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

    pub fn green_node_by_name(&self, name: L::Syntax) -> Option<&Group<L>> {
        self.green_children().find(|it| it.kind == name)
    }

    pub fn lexeme_by_kind(&self, name: L::Token) -> Option<&Lexeme<L>> {
        self.children.iter().find_map(|it| {
            if let Node::Lexeme(l) = it
                && l.kind == name
            {
                Some(l)
            } else {
                None
            }
        })
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

impl<L: Lang> Node<L> {
    /// Iterate over all `Lexeme`s inside this node (DFS, left-to-right).
    pub fn lexemes(&self) -> LexemeIter<'_, L> {
        LexemeIter { stack: vec![self] }
    }

    pub fn errors(&self) -> ErrorIter<'_, L> {
        ErrorIter {
            stack: vec![self],
            offset: 0,
        }
    }

    pub fn start_offset(&self) -> usize {
        match self {
            Node::Group(group) => group.start_offset(),
            Node::Lexeme(lexeme) => lexeme.span.start,
            Node::Err(parse_error) => parse_error.start,
        }
    }

    pub fn end_offset(&self) -> usize {
        match self {
            Node::Group(group) => group.end_offset(),
            Node::Lexeme(lexeme) => lexeme.span.end,
            Node::Err(parse_error) => parse_error
                .actual
                .last()
                .map(|it| it.span.end)
                .unwrap_or(parse_error.start),
        }
    }

    pub fn span(&self) -> Span {
        self.start_offset()..self.end_offset()
    }

    pub fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Node::Group(group) => group.fmt(f),
            Node::Lexeme(lexeme) => write!(f, "{}", &lexeme.text),
            Node::Err(parse_error) => {
                for lexeme in &parse_error.actual {
                    write!(f, "{}", &lexeme.text)?
                }
                Ok(())
            }
        }
    }
}

impl<L: Lang> Group<L> {
    pub fn errors(&self) -> ErrorIter<'_, L> {
        let mut stack = vec![];
        for child in self.children.iter().rev() {
            stack.push(child);
        }
        ErrorIter { stack, offset: 0 }
    }

    pub fn start_offset(&self) -> usize {
        if let Some(first) = self.children.first() {
            first.start_offset()
        } else {
            0
        }
    }

    pub fn end_offset(&self) -> usize {
        if let Some(first) = self.children.last() {
            first.end_offset()
        } else {
            0
        }
    }

    pub fn span(&self) -> Span {
        self.start_offset()..self.end_offset()
    }

    pub fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        for child in &self.children {
            child.fmt(f)?
        }
        Ok(())
    }
}

pub struct LexemeIter<'a, L: Lang> {
    stack: Vec<&'a Node<L>>,
}

impl<'a, L: Lang> Iterator for LexemeIter<'a, L> {
    type Item = &'a Lexeme<L>;

    fn next(&mut self) -> Option<Self::Item> {
        while let Some(node) = self.stack.pop() {
            match node {
                Node::Lexeme(l) => return Some(l),
                Node::Group(g) => {
                    // push children in reverse so we visit in original order
                    for child in g.children.iter().rev() {
                        self.stack.push(child);
                    }
                }
                Node::Err(_) => {
                    // ParseError contents are not part of the tree proper; skip.
                }
            }
        }
        None
    }
}

pub struct ErrorIter<'a, L: Lang> {
    stack: Vec<&'a Node<L>>,
    offset: usize,
}

impl<'a, L: Lang> Iterator for ErrorIter<'a, L> {
    type Item = (usize, &'a ParseError<L>);

    fn next(&mut self) -> Option<Self::Item> {
        while let Some(node) = self.stack.pop() {
            match node {
                Node::Lexeme(l) => {
                    self.offset = l.span.end;
                }
                Node::Group(g) => {
                    // push children in reverse so we visit in original order
                    for child in g.children.iter().rev() {
                        self.stack.push(child);
                    }
                }
                Node::Err(e) => return Some((self.offset, e)),
            }
        }
        None
    }
}
