use std::{fmt::Debug, ops::Range};

use crate::{expected::ExpectedData, lang::CompiledLang, vec::RawVec};

use super::{err::ParseError, lang::Lang};
use ansi_term::Colour::{Blue, Green, Red};

pub type Span = Range<usize>;

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Lexeme<L: Lang> {
    pub span: Span,
    pub kind: L::Token,
    pub text: String,
}

#[repr(C)]
#[derive(Debug, Clone, PartialEq, Eq, Copy)]
pub struct LexemeData {
    pub kind: usize,
    pub start: usize,
    pub end: usize,
}

impl Lexeme<CompiledLang> {
    pub fn from_data(value: LexemeData, src: &str) -> Self {
        Lexeme {
            span: value.start..value.end,
            kind: value.kind as u32,
            text: src[value.start..value.end].to_string(),
        }
    }
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

    fn debug_at(&self, offset: usize, errors: bool, tokens: bool, lang: &L) {
        fn print_offset(n: usize) {
            for _ in 0..n {
                print!("  ");
            }
        }
        match self {
            Node::Group(Group { kind, children }) => {
                print_offset(offset);
                println!("{}", Green.paint(lang.syntax_name(kind)));
                for child in children.iter() {
                    child.debug_at(offset + 1, errors, tokens, lang);
                }
            }
            Node::Lexeme(lexeme) => {
                if tokens {
                    print_offset(offset);
                    println!(
                        "{}: {:?}",
                        Blue.paint(lang.token_name(&lexeme.kind)),
                        lexeme.text
                    )
                }
            }
            Node::Err(err_group) => {
                if errors {
                    print_offset(offset);
                    err_group.debug_at(offset, lang)
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

    pub fn debug_print(&self, errors: bool, tokens: bool, lang: &L) {
        self.debug_at(0, errors, tokens, lang);
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

    pub fn at_offset(&self, offset: usize) -> Option<&Node<L>> {
        match self {
            Node::Group(group) => group.children.iter().find_map(|it| it.at_offset(offset)),
            Node::Lexeme(Lexeme { span, .. }) if span.start <= offset && offset <= span.end => {
                Some(self)
            }
            Node::Err(err) if err.span().start <= offset && offset <= err.span().end => Some(self),
            _ => None,
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
    fn debug_at(&self, offset: usize, lang: &L) {
        // NOTE: Only works when called by outer 'debug_at'
        match self {
            ParseError::MissingError { expected, .. } => {
                let expected = expected
                    .iter()
                    .map(|it| it.debug_name(lang))
                    .collect::<Vec<_>>()
                    .join(",");
                println!("Missing: {expected}");
            }
            ParseError::Unexpected { actual, .. } => {
                println!("Unexpected:");
                for token in actual {
                    for _ in 0..offset {
                        print!("  ");
                    }
                    println!(
                        "  {}: {:?}",
                        Red.paint(lang.token_name(&token.kind)),
                        token.text
                    )
                }
            }
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
            Node::Err(parse_error) => parse_error.start(),
        }
    }

    pub fn end_offset(&self) -> usize {
        match self {
            Node::Group(group) => group.end_offset(),
            Node::Lexeme(lexeme) => lexeme.span.end,
            Node::Err(parse_error) => parse_error
                .actual()
                .last()
                .map(|it| it.span.end)
                .unwrap_or(parse_error.start()),
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
                for lexeme in parse_error.actual() {
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
        for child in self.children.iter() {
            child.fmt(f)?
        }
        Ok(())
    }

    pub fn lexemes(&self) -> impl Iterator<Item = &Lexeme<L>> {
        self.children.iter().flat_map(|it| it.lexemes())
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

#[repr(C)]
#[derive(Clone, Copy)]
pub struct NodeData {
    kind: u32,
    group_kind: u32,
    payload: NodeDataPayload,
}

#[derive(Clone, Copy)]
#[repr(C)]
pub union NodeDataPayload {
    pub lexeme: LexemeData,
    pub node_vec: RawVec<NodeData>,
    pub lexeme_vec: RawVec<LexemeData>,
    pub expected_vec: RawVec<ExpectedData>,
}

impl Node<CompiledLang> {
    pub fn from_data(value: NodeData, src: &str, offset: &mut usize) -> Self {
        match value.kind {
            0 => {
                let payload = unsafe { value.payload.lexeme };
                *offset = payload.end;
                Node::Lexeme(Lexeme {
                    span: payload.start..payload.end,
                    kind: payload.kind as u32,
                    text: src[payload.start..payload.end].to_string(),
                })
            }

            1 => unsafe {
                let children = Vec::from(value.payload.node_vec);
                Node::Group(Group {
                    kind: value.group_kind,
                    children: children
                        .into_iter()
                        .map(|it| Node::from_data(it, src, offset))
                        .collect(),
                })
            },
            2 => unsafe {
                let tokens = Vec::from(value.payload.lexeme_vec)
                    .into_iter()
                    .map(|it| Lexeme::from_data(it, src))
                    .collect::<Vec<_>>();
                if let Some(last) = tokens.last() {
                    *offset = last.span.end;
                }

                Node::Err(ParseError::Unexpected {
                    actual: tokens,
                    start: *offset,
                })
            },
            3 => unsafe {
                let expected = Vec::from(value.payload.expected_vec);
                Node::Err(ParseError::MissingError {
                    start: *offset,
                    expected: expected.into_iter().map(|it| it.into()).collect(),
                })
            },
            id => panic!("Unexpected node id '{id}'"),
        }
    }
}
