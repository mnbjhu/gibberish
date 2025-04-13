use crate::dsl::Parser;

use super::{
    err::{Expected, ParseError},
    lang::Lang,
    node::{Group, Lexeme, Node},
    res::PRes,
};

pub struct ParserState<L: Lang> {
    stack: Vec<Node<L>>,
    input: Vec<Lexeme<L>>,
    errors: Vec<ParseError<L>>,
    current_err: Option<ParseError<L>>,
    offset: usize,
    delim_stack: Vec<Parser<L>>,
}

impl<L: Lang> ParserState<L> {
    pub fn new(input: Vec<Lexeme<L>>) -> ParserState<L> {
        ParserState {
            stack: vec![Node::Group(Group {
                kind: L::root(),
                errors: vec![],
                children: vec![],
            })],
            input,
            errors: vec![],
            current_err: None,
            offset: 0,
            delim_stack: vec![],
        }
    }

    pub fn current(&self) -> Option<&Lexeme<L>> {
        self.input.get(self.offset)
    }

    pub fn bump(&mut self) {
        let current = self.current().expect("Called bump at EOF").clone();
        self.stack
            .last_mut()
            .expect("Tree has no root node")
            .push_tok(current);
        self.offset += 1;
        self.finish_err();
    }

    pub fn bump_err(&mut self, expected: Vec<Expected<L>>) {
        let tok = self.current().cloned();
        if let Some(tok) = tok {
            self.offset += 1;
            if let Some(err) = &mut self.current_err {
                err.actual.push(Some(tok.kind));
            } else {
                self.current_err = Some(ParseError {
                    expected,
                    actual: vec![Some(tok.kind)],
                })
            }
        } else {
            let err = ParseError {
                expected,
                actual: vec![None],
            };
            self.stack
                .last_mut()
                .expect("Tree has no root node")
                .push_err(err);
        }
    }

    pub fn finish_err(&mut self) {
        let err = self.current_err.take();
        if let Some(err) = err {
            self.stack
                .last_mut()
                .expect("Tree has no root node")
                .push_err(err);
        }
    }

    pub fn try_delim(&self) -> Option<usize> {
        self.delim_stack
            .iter()
            .position(|it| it.peak(self) == PRes::Ok)
    }

    pub fn push_delim(&mut self, delim: Parser<L>) {
        self.delim_stack.push(delim);
    }
    pub fn pop_delim(&mut self) {
        self.delim_stack
            .pop()
            .expect("Attempted to pop delim but stack was empty");
    }

    pub fn try_parse(&mut self, parser: &Parser<L>) -> PRes {
        loop {
            let res = parser.parse(self);
            match res {
                PRes::Err => {
                    self.bump_err(parser.expected());
                }
                PRes::Eof => {
                    self.bump_err(parser.expected());
                    break;
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
            errors: vec![],
            children: vec![],
        }));
    }

    pub fn exit(&mut self) {
        let node = self.stack.pop().expect("Node stack underflow");
        let current = self.stack.last_mut().expect("Node stack underflow");
        match current {
            Node::Group(Group { children, .. }) => children.push(node),
            Node::Lexeme(_) => panic!("Cannot push child to lexeme"),
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
            group.errors.extend(disolved.errors);
        } else {
            panic!("Expected a group")
        }
    }

    pub fn has_more(&self) -> bool {
        self.input.len() <= self.offset
    }
}
