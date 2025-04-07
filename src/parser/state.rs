use crate::dsl::Parser;

use super::{
    err::ParseError,
    lang::Lang,
    node::{Lexeme, Node},
    res::PRes,
};

pub struct ParserState<L: Lang> {
    stack: Vec<Node<L>>,
    input: Vec<Lexeme<L>>,
    errors: Vec<ParseError<L>>,
    current_err: ParseError<L>,
    offset: usize,
    delim_stack: Vec<Parser<L>>,
}

impl<L: Lang> ParserState<L> {
    pub fn current(&self) -> &Lexeme<L> {
        self.input
            .get(self.offset)
            .unwrap_or_else(|| panic!("Index {} is out of range for the input", self.offset))
    }

    pub fn bump(&mut self) {
        let current = self.current().clone();
        self.stack
            .last_mut()
            .expect("Tree has no root node")
            .push_tok(current);
        self.finish_err();
    }

    pub fn bump_err(&mut self) {}

    pub fn finish_err(&mut self) {
        todo!()
    }

    pub fn try_delim(&self) -> Option<usize> {
        self.delim_stack
            .iter()
            .position(|it| it.peak(&self) == PRes::Ok)
    }

    // TODO: Maybe think about this
    pub fn parse_delim(&mut self, index: usize) -> PRes {
        // TODO: L-CLone
        let parser = self.delim_stack[index].clone();
        parser.parse(self)
    }

    pub fn push_delim(&mut self, delim: Parser<L>) {
        self.delim_stack.push(delim);
    }

    pub fn try_parse(&mut self, parser: &Parser) {
        loop {
            let res = parser.parse(self);
            match res {
                PRes::Err => {
                    state.bump_err();
                }
                PRes::Break(_) => return res,
                PRes::Ok => break,
            }
        }
    }
}
