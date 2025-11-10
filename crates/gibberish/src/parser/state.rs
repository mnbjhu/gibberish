use std::collections::HashSet;

use ariadne::Span;
use tracing::debug;

use crate::api::{
    Parser,
    ptr::{ParserCache, ParserIndex},
};

use super::{
    err::{Expected, ParseError},
    lang::Lang,
    node::{Group, Lexeme, Node},
    res::PRes,
};

#[derive(Debug)]
pub struct ParserState<'a, L: Lang> {
    stack: Vec<Node<L>>,
    input: Vec<Lexeme<L>>,
    offset: usize,
    delim_stack: Vec<ParserIndex<L>>,
    skipping: HashSet<L::Token>,
    pub cache: &'a ParserCache<L>,
}

impl<'a, L: Lang> ParserState<'a, L> {
    pub fn new(input: Vec<Lexeme<L>>, cache: &'a ParserCache<L>) -> ParserState<'a, L> {
        ParserState {
            stack: vec![Node::Group(Group {
                kind: cache.lang.root(),
                children: vec![],
            })],
            input,
            offset: 0,
            delim_stack: vec![],
            skipping: HashSet::new(),
            cache,
        }
    }

    pub fn current(&self) -> Option<&Lexeme<L>> {
        self.input.get(self.offset)
    }

    pub fn at_offset(&self, offset: usize) -> Option<&Lexeme<L>> {
        self.input.get(self.offset + offset)
    }

    pub fn bump(&mut self) {
        let current = self.current().expect("Called bump at EOF").clone();
        debug!("Bumping token {current:?}");
        self.stack
            .last_mut()
            .expect("Tree has no root node")
            .push_tok(current.clone());
        self.offset += 1;
        self.bump_skipped();
    }

    pub fn bump_skipped(&mut self) {
        while let Some(current) = self.current().cloned() {
            if self.skipping.contains(&current.kind) {
                self.stack
                    .last_mut()
                    .expect("Tree has no root node")
                    .push_tok(current);
                self.offset += 1;
            } else {
                break;
            }
        }
    }

    pub fn skip(&mut self, token: L::Token) -> bool {
        self.skipping.insert(token)
    }

    pub fn unskip(&mut self, token: L::Token) -> bool {
        self.skipping.remove(&token)
    }

    pub fn eof_offset(&self) -> usize {
        self.input.last().map(|it| it.span.end()).unwrap_or(0)
    }

    pub fn bump_err(&mut self, expected: Vec<Expected<L>>) {
        let current = self.current().cloned();
        let start = if let Some(current) = &current {
            self.offset += 1;
            current.span.end
        } else {
            self.eof_offset()
        };
        let err = if let Some(Node::Err(err)) = self.current_group_mut().children.last_mut() {
            err
        } else {
            self.current_group_mut()
                .children
                .push(Node::Err(ParseError::Unexpected {
                    start,
                    expected,
                    actual: vec![],
                }));
            let Node::Err(err) = self.current_group_mut().children.last_mut().unwrap() else {
                panic!()
            };
            err
        };

        if let Some(current) = current {
            err.actual_mut().push(current.clone());
        }
        self.bump_skipped();
    }

    pub fn try_delim(&self) -> Option<usize> {
        let res = self
            .delim_stack
            .iter()
            .enumerate()
            .rev()
            .find_map(|(n, it)| {
                if it.get_ref(self.cache).peak(self, false, self.after_skip()) == PRes::Ok {
                    Some(n)
                } else {
                    None
                }
            });
        if let Some(index) = res {
            debug!("Hit delim: {index}");
        }
        res
    }

    #[must_use]
    pub fn push_delim(&mut self, delim: ParserIndex<L>) -> usize {
        let index = self.delim_stack.len();
        debug!("Added delim to stack {:?}", delim.get_ref(self.cache));
        self.delim_stack.push(delim);
        index
    }
    pub fn pop_delim(&mut self) {
        let removed = self
            .delim_stack
            .pop()
            .expect("Attempted to pop delim but stack was empty");
        debug!("Removed delim from stack {:?}", removed.get_ref(self.cache));
    }

    pub fn try_parse(&mut self, parser: &'a Parser<L>, recover: bool) -> (PRes, bool) {
        let mut bumped = false;
        loop {
            let res = parser.do_parse(self, recover);
            match res {
                PRes::Err => {
                    bumped = true;
                    self.bump_err(parser.expected(self.cache));
                }
                PRes::Eof => {
                    return (PRes::Eof, bumped);
                }
                PRes::Break(_) => return (res, bumped),
                PRes::Ok => break,
            }
        }
        (PRes::Ok, bumped)
    }

    pub fn maybe_parse(&mut self, parser: &'a Parser<L>, recover: bool) -> PRes {
        loop {
            let res = parser.do_parse(self, recover);
            match res {
                PRes::Err => {
                    self.bump_err(parser.expected(self.cache));
                }
                PRes::Eof => {
                    return PRes::Eof;
                }
                PRes::Break(_) => return res,
                PRes::Ok => break,
            }
        }
        PRes::Ok
    }

    pub fn enter(&mut self, name: L::Syntax) {
        self.stack.push(Node::Group(Group {
            kind: name,
            children: vec![],
        }));
    }

    pub fn exit(&mut self) {
        let node = self.stack.pop().expect("Node stack underflow");
        let current = self.stack.last_mut().expect("Node stack underflow");
        if let Node::Group(Group { children, .. }) = current {
            children.push(node)
        } else {
            panic!("Expected a group")
        }
    }

    pub fn finish(mut self) -> Node<L> {
        assert_eq!(self.stack.len(), 1);
        self.stack.pop().unwrap()
    }

    pub fn disolve_name(&mut self) {
        let Node::Group(disolved) = self.stack.pop().unwrap() else {
            panic!("Expected a group")
        };
        if let Node::Group(group) = self.stack.last_mut().unwrap() {
            group.children.extend(disolved.children);
        } else {
            panic!("Expected a group")
        }
    }

    pub fn current_group(&self) -> &Group<L> {
        if let Node::Group(g) = self.stack.last().unwrap() {
            g
        } else {
            panic!("Stack item is not a group")
        }
    }
    pub fn current_group_mut(&mut self) -> &mut Group<L> {
        if let Node::Group(g) = self.stack.last_mut().unwrap() {
            g
        } else {
            panic!("Stack item is not a group")
        }
    }

    pub fn missing_delim(&mut self, parser: &'a Parser<L>, start_delim: Lexeme<L>) {
        let current = self.current();
        let expected = parser.expected(self.cache);
        if let Some(Node::Err(err)) = self.current_group().children.last()
            && err.expected() == &expected
        {
            return;
        }
        let start = if let Some(current) = &current {
            current.span.end
        } else {
            self.eof_offset()
        };
        let before = self.current().cloned();
        self.current_group_mut()
            .children
            .push(Node::Err(ParseError::MissingError {
                start,
                expected,
                actual: vec![],
                before,
                start_delim,
            }));
    }

    pub fn missing(&mut self, parser: &'a Parser<L>) {
        let expected = parser.expected(self.cache);
        if let Some(Node::Err(err)) = self.current_group().children.last()
            && err.expected() == &expected
        {
            return;
        }
        let current = self.current();
        let start = if let Some(current) = &current {
            current.span.start
        } else {
            self.eof_offset()
        };
        self.current_group_mut()
            .children
            .push(Node::Err(ParseError::Unexpected {
                start,
                expected,
                actual: vec![],
            }));
    }

    pub fn current_err(&mut self) -> Option<&mut ParseError<L>> {
        if let Node::Err(err) = self.current_group_mut().children.last_mut()? {
            Some(err)
        } else {
            None
        }
    }

    pub fn after_skip(&self) -> usize {
        let mut res = 0;
        while let Some(current) = self.at_offset(res) {
            if self.skipping.contains(&current.kind) {
                res += 1;
            } else {
                break;
            }
        }
        res
    }

    pub fn after_white_space(&self, mut offset: usize) -> usize {
        while let Some(current) = self.at_offset(offset) {
            if self.skipping.contains(&current.kind) {
                offset += 1;
            } else {
                break;
            }
        }
        offset
    }

    pub fn recover_index(&self) -> usize {
        self.delim_stack.len()
    }
}
