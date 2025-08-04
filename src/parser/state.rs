use rowan::{Checkpoint, GreenNode, GreenNodeBuilder};
use std::collections::HashSet;
use tracing::info;

use crate::api::Parser;

use super::{
    err::{Expected, ParseError},
    lang::Lang,
    node::Lexeme,
    res::PRes,
};

#[derive(Debug)]
pub struct ParserState<L: Lang> {
    // stack: Vec<Node<L>>,
    builder: GreenNodeBuilder<'static>,
    input: Vec<Lexeme<L>>,
    offset: usize,
    delim_stack: Vec<Parser<L>>,
    errors: Vec<ParseError<L>>,
    current_err: Option<ParseError<L>>,
    skipping: HashSet<L::Kind>,
}

impl<L: Lang> ParserState<L> {
    pub fn new(input: Vec<Lexeme<L>>) -> ParserState<L> {
        ParserState {
            input,
            offset: 0,
            delim_stack: vec![],
            builder: GreenNodeBuilder::new(),
            errors: vec![],
            current_err: None,
            skipping: HashSet::new(),
        }
    }

    pub fn current(&self) -> Option<&Lexeme<L>> {
        self.input.get(self.offset)
    }

    pub fn bump(&mut self) {
        let current = self.current().expect("Called bump at EOF").clone();
        info!("Bumping token {current:?}");
        self.builder
            .token(L::kind_to_raw(current.kind), &current.text);
        self.offset += 1;
    }

    pub fn skip(&mut self, token: L::Kind) -> bool {
        self.skipping.insert(token)
    }

    pub fn unskip(&mut self, token: L::Kind) -> bool {
        self.skipping.remove(&token)
    }

    pub fn bump_err(&mut self, expected: Vec<Expected<L>>) {
        let current = self.current().cloned();
        if let Some(err) = &mut self.current_err {
            err.actual.push(current.unwrap().clone().kind);
        } else {
            let err = ParseError {
                expected,
                actual: vec![current.unwrap().clone().kind],
            };
            self.current_err = Some(err)
        };
        self.bump();
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

    pub fn finish_err(&mut self) {
        let err = self.current_err.take().unwrap();
        self.errors.push(err);
    }

    pub fn enter(&mut self, name: L::Kind) {
        self.builder.start_node(L::kind_to_raw(name));
    }

    pub fn exit(&mut self) {
        self.builder.finish_node();
    }

    pub fn finish(self) -> GreenNode {
        self.builder.finish()
    }

    pub fn checkpoint(&mut self) -> Checkpoint {
        self.builder.checkpoint()
    }

    pub fn start_node_at(&mut self, checkpoint: Checkpoint, kind: L::Kind) {
        self.builder.start_node_at(checkpoint, L::kind_to_raw(kind));
    }

    pub fn missing(&mut self, parser: &Parser<L>) {
        let expected = parser.expected();
        if self.current_err.is_some() {
            self.finish_err()
        }
        self.errors.push(ParseError {
            expected,
            actual: vec![],
        });
    }
}
