use std::rc::{Rc, Weak};

use crate::parser::{err::Expected, lang::Lang, res::PRes, state::ParserState};

use super::Parser;

#[derive(Debug, Clone)]
pub enum Recursive<'src, L: Lang<'src>> {
    Ptr(Rc<Parser<'src, L>>),
    Weak(Weak<Parser<'src, L>>),
}

impl<'src, L: Lang<'src>> Recursive<'src, L> {
    pub fn parse(&self, state: &mut ParserState<'src, L>, recover: bool) -> PRes {
        match self {
            Recursive::Ptr(parser) => parser.do_parse(state, recover),
            Recursive::Weak(weak) => weak.upgrade().unwrap().do_parse(state, recover),
        }
    }

    pub fn peak(&self, state: &ParserState<'src, L>, recover: bool) -> PRes {
        match self {
            Recursive::Ptr(parser) => parser.peak(state, recover),
            Recursive::Weak(weak) => weak.upgrade().unwrap().peak(state, recover),
        }
    }

    pub fn expected(&'src self) -> Vec<Expected<'src, L>> {
        match self {
            Recursive::Ptr(parser) => parser.expected(),
            Recursive::Weak(weak) => weak.upgrade().unwrap().expected(),
        }
    }
}

pub fn recursive<'src, L: Lang<'src>>(builder: impl Fn(Parser<L>) -> Parser<L>) -> Parser<'src, L> {
    let res = Rc::new_cyclic(|p| builder(Parser::Rec(Recursive::Weak(p.clone()))));
    Parser::Rec(Recursive::Ptr(res))
}
