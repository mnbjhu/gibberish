use crate::{
    api::{Parser, choice::choice, just::just, maybe::Requirement, none_of::none_of, seq::seq},
    giblang::{
        parser::decl::{enum_::enum_parser, func::func_parser, struct_::struct_parser},
        syntax::GSyntax,
    },
};

use super::{lang::GLang, lexer::GToken};

pub mod common;
pub mod decl;
pub mod expr;
pub mod pattern;
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

pub fn qualified_name() -> Parser<GLang> {
    just(GToken::Ident)
        .named(GSyntax::Name)
        .fold(
            GSyntax::QualifiedName,
            seq(vec![
                just(GToken::DoubleColon),
                just(GToken::Ident).named(GSyntax::Name),
            ]),
        )
        .unskip(GToken::Whitespace)
        .unskip(GToken::Newline)
        .break_at(none_of(vec![GToken::Ident, GToken::DoubleColon]))
}

// pub fn stmt_parser() -> Parser<GLang> {}
// pub fn expr_parser(stmt: Parser<GLang>) -> Parser<GLang> {}
