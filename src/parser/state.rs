use tracing::{info, warn};

use crate::dsl::Parser;

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
        info!("Bumping token {current:?}");
        self.stack
            .last_mut()
            .expect("Tree has no root node")
            .push_tok(current);
        self.offset += 1;
        self.finish_err();
    }

    pub fn bump_err(&mut self, expected: Vec<Expected<L>>) {
        let tok = self.current().cloned();
        warn!(
            "Bumping error {}",
            tok.as_ref()
                .map(|t| t.kind.to_string())
                .unwrap_or("EOF".to_string())
        );
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
        let res = self
            .delim_stack
            .iter()
            .position(|it| it.peak(self, true) == PRes::Ok);
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

    pub fn error(&mut self, err: ParseError<L>) {
        self.stack.last_mut().unwrap().push_err(err);
    }

    pub fn missing(&mut self, parser: &Parser<L>) {
        self.error(ParseError {
            expected: parser.expected(),
            actual: vec![],
        });
    }
}
