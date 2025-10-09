use std::fmt::Display;

use crate::{
    api::ptr::{ParserCache, ParserIndex},
    parser::{err::Expected, lang::Lang, res::PRes, state::ParserState},
};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct TokSeq<L: Lang>(pub Vec<L::Token>);

impl<'a, L: Lang> TokSeq<L> {
    pub fn parse(&self, state: &mut ParserState<L>) -> PRes {
        for (index, expected) in self.0.iter().enumerate() {
            let Some(tok) = state.current() else {
                if index == 0 {
                    return PRes::Eof;
                } else {
                    return PRes::Ok;
                }
            };
            if &tok.kind == expected {
                state.bump();
            } else if let Some(pos) = state.try_delim() {
                if index == 0 {
                    return PRes::Break(pos);
                } else {
                    return PRes::Ok;
                }
            } else {
                // state.bump_err(self.expected());
                return PRes::Err;
            }
        }
        PRes::Ok
    }

    pub fn peak(&self, state: &ParserState<L>, recover: bool, mut offset: usize) -> PRes {
        for (index, expected) in self.0.iter().enumerate() {
            let Some(tok) = state.at_offset(offset) else {
                if index == 0 {
                    return PRes::Eof;
                } else {
                    return PRes::Err;
                }
            };
            if tok.kind == *expected {
                offset = state.after_white_space(offset + 1);
            } else if recover && let Some(pos) = state.try_delim() {
                if index == 0 {
                    return PRes::Break(pos);
                } else {
                    return PRes::Err;
                }
            }
        }
        PRes::Ok
    }

    pub fn expected(&self) -> Vec<Expected<L>> {
        vec![Expected::Token(self.0[0].clone())]
    }
}

pub fn just_seq<L: Lang>(tok: Vec<L::Token>, cache: &mut ParserCache<L>) -> ParserIndex<L> {
    let p = Parser::TokSeq(TokSeq(tok));
    p.cache(cache)
}

impl<L: Lang> Display for TokSeq<L> {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(
            f,
            "Just({})",
            self.0
                .iter()
                .map(L::Token::to_string)
                .collect::<Vec<_>>()
                .join(", ")
        )
    }
}
