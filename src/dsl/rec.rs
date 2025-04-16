use std::rc::{Rc, Weak};

use crate::parser::{err::Expected, lang::Lang, res::PRes, state::ParserState};

use super::Parser;

#[derive(Debug, Clone)]
pub enum Recursive<L: Lang> {
    Ptr(Rc<Parser<L>>),
    Weak(Weak<Parser<L>>),
}

impl<L: Lang> Recursive<L> {
    pub fn parse(&self, state: &mut ParserState<L>) -> PRes {
        match self {
            Recursive::Ptr(parser) => parser.do_parse(state),
            Recursive::Weak(weak) => weak.upgrade().unwrap().do_parse(state),
        }
    }

    pub fn peak(&self, state: &ParserState<L>) -> PRes {
        match self {
            Recursive::Ptr(parser) => parser.peak(state),
            Recursive::Weak(weak) => weak.upgrade().unwrap().peak(state),
        }
    }

    pub fn expected(&self) -> Vec<Expected<L>> {
        match self {
            Recursive::Ptr(parser) => parser.expected(),
            Recursive::Weak(weak) => weak.upgrade().unwrap().expected(),
        }
    }
}

pub fn recursive<L: Lang>(builder: impl Fn(Parser<L>) -> Parser<L>) -> Parser<L> {
    let res = Rc::new_cyclic(|p| builder(Parser::Rec(Recursive::Weak(p.clone()))));
    Parser::Rec(Recursive::Ptr(res))
}
