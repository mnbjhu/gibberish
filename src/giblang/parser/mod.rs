use crate::{
    api::{Parser, choice::choice, just::just, maybe::Requirement},
    giblang::parser::decl::{enum_::enum_parser, func::func_parser, struct_::struct_parser},
};

use super::{lang::GLang, lexer::GToken};

pub mod decl;
pub mod expr;
pub mod stmt;
pub mod ty;

pub fn g_parser() -> Parser<GLang> {
    decl_parser()
        .sep_by_extra(
            just(GToken::Newline),
            Requirement::Maybe,
            Requirement::Maybe,
        )
        .skip(GToken::Whitespace)
}

pub fn decl_parser() -> Parser<GLang> {
    choice(vec![struct_parser(), enum_parser(), func_parser()])
}

// pub fn stmt_parser() -> Parser<GLang> {}
// pub fn expr_parser(stmt: Parser<GLang>) -> Parser<GLang> {}
