use tracing::info;

use crate::api::Parser;

use super::{
    err::{Expected, ParseError},
    lang::Lang,
    node::{Group, Lexeme, Node},
    res::PRes,
};

#[derive(Debug)]
pub struct ParserState<L: Lang> {
    stack: Vec<Node<L>>,
    input: Vec<Lexeme<L>>,
    offset: usize,
    delim_stack: Vec<Parser<L>>,
}

impl<L: Lang> ParserState<L> {
    pub fn new(input: Vec<Lexeme<L>>) -> ParserState<L> {
        ParserState {
            stack: vec![Node::Group(Group {
                kind: L::root(),
                children: vec![],
            })],
            input,
            offset: 0,
            delim_stack: vec![],
        }
    }

    pub fn current(&self) -> Option<&Lexeme<L>> {
        self.input.get(self.offset)
    }

    pub fn bump(&mut self) {
        let current = self.current().expect("Called bump at EOF").clone();
        info!("Bumping token {current:?}");
        self.stack
            .last_mut()
            .expect("Tree has no root node")
            .push_tok(current);
        self.offset += 1;
    }

    pub fn bump_err(&mut self, expected: Vec<Expected<L>>) {
        let current = self.current().cloned();
        if current.is_some() {
            self.offset += 1;
        }
        let err = if let Node::Err(err) = self.current_group_mut().children.last_mut().unwrap() {
            err
        } else {
            self.current_group_mut()
                .children
                .push(Node::Err(ParseError {
                    expected,
                    actual: vec![],
                }));
            let Node::Err(err) = self.current_group_mut().children.last_mut().unwrap() else {
                unreachable!()
            };
            err
        };

        if let Some(current) = current {
            err.actual.push(current.clone());
        }
    }

    pub fn try_delim(&self) -> Option<usize> {
        let res = self
            .delim_stack
            .iter()
            .enumerate()
            .rev()
            .find_map(|(n, it)| {
                if it.peak(self, true) == PRes::Ok {
                    Some(n)
                } else {
                    None
                }
            });
        if let Some(index) = res {
            info!("Hit delim: {index}");
        }
        res
    }

    #[must_use]
    pub fn push_delim(&mut self, delim: Parser<L>) -> usize {
        let index = self.delim_stack.len();
        self.delim_stack.push(delim);
        index
    }
    pub fn pop_delim(&mut self) {
        self.delim_stack
            .pop()
            .expect("Attempted to pop delim but stack was empty");
    }

    pub fn try_parse(&mut self, parser: &Parser<L>, recover: bool) -> PRes {
        loop {
            let res = parser.do_parse(self, recover);
            match res {
                PRes::Err => {
                    self.bump_err(parser.expected());
                }
                PRes::Eof => {
                    self.bump_err(parser.expected());
                    return PRes::Eof;
                }
                PRes::Break(_) => return res,
                PRes::Ok => break,
            }
        }
        PRes::Ok
    }

    pub fn maybe_parse(&mut self, parser: &Parser<L>, recover: bool) -> PRes {
        loop {
            let res = parser.do_parse(self, recover);
            match res {
                PRes::Err => {
                    self.bump_err(parser.expected());
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

    pub fn missing(&mut self, parser: &Parser<L>) {
        let expected = parser.expected();
        if let Some(Node::Err(err)) = self.current_group().children.last() {
            if err.expected == expected {
                return;
            }
        }
        self.current_group_mut()
            .children
            .push(Node::Err(ParseError {
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
}
