use crate::api::{Parser, choice::choice, just::just, rec::recursive, seq::seq};

use super::{lang::GLang, lexer::GToken, syntax::GSyntax};

pub fn g_parser() -> Parser<GLang> {
    decl_parser()
        .skip(GToken::Newline)
        .sep_by(just(GToken::Newline))
        .skip(GToken::Whitespace)
}

pub fn decl_parser() -> Parser<GLang> {
    choice(vec![struct_parser()])
}

pub fn struct_parser() -> Parser<GLang> {
    seq(vec![
        just(GToken::Struct),
        just(GToken::Ident).named(GSyntax::TypeName),
        struct_body_parser(),
    ])
}

pub fn struct_body_parser() -> Parser<GLang> {
    let field = seq(vec![
        just(GToken::Ident).named(GSyntax::FieldName),
        just(GToken::Colon),
        type_parser(),
    ]);
    let fields = field
        .sep_by(just(GToken::Comma))
        .delim_by(just(GToken::LBrace), just(GToken::RBrace))
        .named(GSyntax::Fields);

    let tuple = type_parser()
        .sep_by(just(GToken::Comma))
        .delim_by(just(GToken::LParen), just(GToken::RParen))
        .named(GSyntax::TupleFields);

    choice(vec![fields, tuple]).or_not()
}

pub fn type_parser() -> Parser<GLang> {
    recursive(|ty| {
        seq(vec![
            just(GToken::Ident).named(GSyntax::TypeName),
            ty.sep_by(just(GToken::Comma))
                .delim_by(just(GToken::LBracket), just(GToken::RBracket))
                .named(GSyntax::TypeArgs)
                .or_not(),
        ])
        .named(GSyntax::Type)
    })
}

// pub fn stmt_parser() -> Parser<GLang> {}
// pub fn expr_parser(stmt: Parser<GLang>) -> Parser<GLang> {}
