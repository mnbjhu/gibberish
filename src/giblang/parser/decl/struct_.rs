use crate::api::{Parser, choice::choice, just::just, maybe::Requirement, seq::seq};
use crate::giblang::parser::ty::type_parser;
use crate::giblang::{lang::GLang, lexer::GToken, syntax::GSyntax};

pub fn struct_parser() -> Parser<GLang> {
    seq(vec![
        just(GToken::Struct),
        just(GToken::Ident).named(GSyntax::TypeName),
        struct_body_parser(),
    ])
    .named(GSyntax::Struct)
}

pub fn struct_body_parser() -> Parser<GLang> {
    let field = seq(vec![
        just(GToken::Ident).named(GSyntax::Name),
        just(GToken::Colon),
        type_parser(),
    ])
    .named(GSyntax::Field);
    let fields = field
        .sep_by_extra(just(GToken::Comma), Requirement::No, Requirement::Maybe)
        .or_not()
        .skip(GToken::Newline)
        .delim_by(just(GToken::LBrace), just(GToken::RBrace))
        .named(GSyntax::Fields);

    let tuple = type_parser()
        .sep_by(just(GToken::Comma))
        .skip(GToken::Newline)
        .delim_by(just(GToken::LParen), just(GToken::RParen))
        .named(GSyntax::TupleFields);

    choice(vec![fields, tuple]).or_not()
}
