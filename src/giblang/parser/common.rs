use std::rc::Rc;

use crate::{
    api::{Parser, custom::CustomParser},
    giblang::{lang::GLang, lexer::GToken},
    parser::{err::Expected, res::PRes, state::ParserState},
};

#[derive(Debug)]
pub struct IdentParser;

impl CustomParser<GLang> for IdentParser {
    fn parse(&self, state: &mut ParserState<GLang>, _: bool) -> PRes {
        let Some(tok) = state.current() else {
            return PRes::Eof;
        };
        if tok.kind == GToken::Ident {
            let Some(tok) = state.at_offset(1) else {
                return PRes::Err;
            };
            if tok.kind != GToken::DoubleColon {
                state.bump();
                PRes::Ok
            } else {
                PRes::Err
            }
        } else if let Some(pos) = state.try_delim() {
            PRes::Break(pos)
        } else {
            // state.bump_err(self.expected());
            PRes::Err
        }
    }

    fn peak(&self, state: &ParserState<GLang>, recover: bool, offset: usize) -> PRes {
        let Some(tok) = state.at_offset(offset) else {
            return PRes::Eof;
        };
        if tok.kind == GToken::Ident {
            let Some(tok) = state.at_offset(offset + 1) else {
                return PRes::Err;
            };
            if tok.kind != GToken::DoubleColon {
                PRes::Ok
            } else {
                PRes::Err
            }
        } else if recover && let Some(pos) = state.try_delim() {
            return PRes::Break(pos);
        } else {
            PRes::Err
        }
    }

    fn expected(&self) -> Vec<Expected<GLang>> {
        vec![Expected::Token(GToken::Ident)]
    }

    fn name(&self) -> String {
        "Ident".to_string()
    }
}

pub fn ident_parser() -> Parser<GLang> {
    Parser::Custom(Rc::new(IdentParser))
}
