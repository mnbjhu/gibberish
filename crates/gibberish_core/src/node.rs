use std::{fmt::Debug, ops::Range};

use crate::{err::Expected, expected::ExpectedData, lang::CompiledLang, vec::RawVec};

use super::{err::ParseError, lang::Lang};
use ansi_term::{
    Color,
    Colour::{Blue, Green, Red},
};

const GREY: Color = Color::RGB(100, 100, 100);

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
    Skipped(Lexeme<L>),
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
                    lexeme.debug_at(offset, lang, false);
                }
            }
            Node::Skipped(lexeme) => {
                if tokens {
                    lexeme.debug_at(offset, lang, true);
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
            Node::Skipped(_) => panic!("Skipped has no name"),
            Node::Err(_) => panic!("ErrGroup has no name"),
        }
    }

    pub fn groups(&self) -> impl Iterator<Item = &Group<L>> {
        match self {
            Node::Group(Group { children, .. }) => children.iter().filter_map(|it| match it {
                Node::Group(group) => Some(group),
                Node::Lexeme(_) => None,
                Node::Skipped(_) => None,
                Node::Err(_) => None,
            }),
            Node::Lexeme(_) => panic!("Lexeme has no children"),
            Node::Err(_) => panic!("ErrGroup has no children"),
            Node::Skipped(_) => panic!("Skipped has no children"),
        }
    }

    pub fn at_offset(&self, offset: usize) -> Option<&Node<L>> {
        match self {
            Node::Group(group) => group.children.iter().find_map(|it| it.at_offset(offset)),
            Node::Skipped(Lexeme { span, .. }) | Node::Lexeme(Lexeme { span, .. })
                if span.start <= offset && offset <= span.end =>
            {
                Some(self)
            }
            Node::Err(err) if err.span().start <= offset && offset <= err.span().end => Some(self),
            _ => None,
        }
    }
}

impl<L: Lang> Lexeme<L> {
    pub fn debug_at(&self, offset: usize, lang: &L, skipped: bool) {
        for _ in 0..offset {
            print!("  ");
        }
        let color = if skipped { GREY } else { Color::Blue };
        println!(
            "{}: {:?}{span}",
            color.paint(lang.token_name(&self.kind)),
            self.text,
            span = GREY.paint(format!("@{:?}", self.span)),
        )
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
                println!("{}: {expected}", Red.paint("Missing"));
            }
            ParseError::Unexpected { actual, .. } => {
                println!("{}", Color::Red.paint("Unexpected:"));
                for token in actual {
                    token.debug_at(offset + 1, lang, false);
                }
            }
        }
    }
}

impl<L: Lang> Node<L> {
    pub fn all_tokens(&self) -> LexemeIter<'_, L> {
        LexemeIter {
            stack: vec![NodeOrLexeme::Node(self)],
        }
    }

    pub fn all_errors(&self) -> ErrorIter<'_, L> {
        ErrorIter {
            stack: vec![self],
            offset: 0,
        }
    }

    pub fn all_leading_errors(&self) -> LeadingErrorIter<'_, L> {
        LeadingErrorIter {
            stack: vec![self],
            offset: 0,
        }
    }

    pub fn start_offset(&self) -> usize {
        match self {
            Node::Group(group) => group.start_offset(),
            Node::Skipped(lexeme) | Node::Lexeme(lexeme) => lexeme.span.start,
            Node::Err(ParseError::Unexpected { actual, .. }) => actual.first().unwrap().span.start,
            Node::Err(ParseError::MissingError { start, .. }) => *start,
        }
    }

    pub fn end_offset(&self) -> usize {
        match self {
            Node::Group(group) => group.end_offset(),
            Node::Lexeme(lexeme) => lexeme.span.end,
            Node::Skipped(lexeme) => lexeme.span.end,
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
            Node::Skipped(lexeme) | Node::Lexeme(lexeme) => write!(f, "{}", &lexeme.text),
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
    pub fn all_errors(&self) -> ErrorIter<'_, L> {
        let mut stack = vec![];
        for child in self.children.iter().rev() {
            stack.push(child);
        }
        ErrorIter { stack, offset: 0 }
    }

    pub fn all_leading_errors(&self) -> LeadingErrorIter<'_, L> {
        let mut stack = vec![];
        for child in self.children.iter().rev() {
            stack.push(child);
        }
        LeadingErrorIter { stack, offset: 0 }
    }

    pub fn all_tokens(&self) -> impl Iterator<Item = &Lexeme<L>> {
        self.children.iter().flat_map(|it| it.all_tokens())
    }

    pub fn name(&self) -> L::Syntax {
        self.kind.clone()
    }

    pub fn groups(&self) -> impl Iterator<Item = &Group<L>> {
        self.children.iter().filter_map(|it| match it {
            Node::Group(group) => Some(group),
            Node::Lexeme(_) => None,
            Node::Skipped(_) => None,
            Node::Err(_) => None,
        })
    }

    pub fn group_at(&self, offset: usize) -> Option<&Group<L>> {
        self.groups().find(|it| it.span().contains(&offset))
    }

    pub fn group_by_kind(&self, name: L::Syntax) -> Option<&Group<L>> {
        self.groups().find(|it| it.kind == name)
    }

    pub fn tokens(&self) -> impl Iterator<Item = &Lexeme<L>> {
        self.children.iter().filter_map(|it| {
            if let Node::Lexeme(l) = it {
                Some(l)
            } else {
                None
            }
        })
    }

    pub fn token_by_kind(&self, name: L::Token) -> Option<&Lexeme<L>> {
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

    pub fn errors(&self) -> impl Iterator<Item = &ParseError<L>> {
        self.children
            .iter()
            .filter_map(|it| if let Node::Err(e) = it { Some(e) } else { None })
    }

    pub fn completions_at(&self, offset: usize) -> Vec<Expected<L>> {
        dbg!("Getting completions for group", self.span());
        let mut index = None;
        let mut res = vec![];
        for (i, child) in self.children.iter().enumerate() {
            if child.span().contains(&offset) {
                if let Node::Group(group) = child {
                    return group.completions_at(offset);
                }
                index = Some(i);
            } else if let Node::Err(ParseError::MissingError { start, expected }) = child
                && *start == offset
            {
                return expected.clone();
            } else {
                dbg!("Child did not match", child.span(), offset);
            }
        }
        if let Some(index) = index {
            for child in &self.children[index..] {
                match child {
                    Node::Group(_) | Node::Lexeme(_) => continue,
                    Node::Skipped(_) => continue,
                    Node::Err(ParseError::MissingError { expected, .. }) => {
                        res.extend(expected.iter().cloned());
                        break;
                    }
                    Node::Err(ParseError::Unexpected { .. }) => continue,
                }
            }
        } else {
            dbg!("Group didn't contain offset", offset, self.span());
        }
        res
    }
}

pub struct LexemeIter<'a, L: Lang> {
    stack: Vec<NodeOrLexeme<'a, L>>,
}

enum NodeOrLexeme<'a, L: Lang> {
    Node(&'a Node<L>),
    Lexeme(&'a Lexeme<L>),
}

impl<'a, L: Lang> Iterator for LexemeIter<'a, L> {
    type Item = &'a Lexeme<L>;

    fn next(&mut self) -> Option<Self::Item> {
        while let Some(node_lex) = self.stack.pop() {
            match node_lex {
                NodeOrLexeme::Node(node) => match node {
                    // TODO: Consider not including skipped tokens
                    Node::Skipped(l) | Node::Lexeme(l) => return Some(l),
                    Node::Group(g) => {
                        for child in g.children.iter().rev() {
                            self.stack.push(NodeOrLexeme::Node(child));
                        }
                    }
                    Node::Err(ParseError::Unexpected { actual, .. }) => {
                        for tok in actual {
                            self.stack.push(NodeOrLexeme::Lexeme(tok));
                        }
                    }
                    Node::Err(ParseError::MissingError { .. }) => {}
                },
                NodeOrLexeme::Lexeme(l) => return Some(l),
            }
        }
        None
    }
}

pub struct LeadingErrorIter<'a, L: Lang> {
    stack: Vec<&'a Node<L>>,
    offset: usize,
}

impl<'a, L: Lang> Iterator for LeadingErrorIter<'a, L> {
    type Item = (usize, &'a ParseError<L>);

    fn next(&mut self) -> Option<Self::Item> {
        let mut first = None;
        while let Some(node) = self.stack.pop() {
            match node {
                Node::Skipped(l) | Node::Lexeme(l) => {
                    if first.is_some() {
                        return first;
                    }
                    self.offset = l.span.end;
                }
                Node::Group(g) => {
                    // push children in reverse so we visit in original order
                    for child in g.children.iter().rev() {
                        self.stack.push(child);
                    }
                }
                Node::Err(e) => {
                    if let ParseError::Unexpected { start, actual } = e {
                        self.offset = actual.iter().last().map(|it| it.span.end).unwrap_or(*start);
                        return Some((self.offset, e));
                    } else if first.is_none() {
                        first = Some((self.offset, e))
                    }
                }
            }
        }
        first
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
                Node::Skipped(l) | Node::Lexeme(l) => {
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
            4 => {
                let payload = unsafe { value.payload.lexeme };
                *offset = payload.end;
                Node::Skipped(Lexeme {
                    span: payload.start..payload.end,
                    kind: payload.kind as u32,
                    text: src[payload.start..payload.end].to_string(),
                })
            }

            id => panic!("Unexpected node id '{id}'"),
        }
    }
}
