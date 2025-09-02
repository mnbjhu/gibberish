use crate::{
    api::{Parser, just::just, seq::seq},
    giblang::{lang::GLang, lexer::GToken, parser::ty::type_parser, syntax::GSyntax},
};

pub fn generic_arg_parser() -> Parser<GLang> {
    seq(vec![
        just(GToken::Ident),
        just(GToken::Colon),
        type_parser(),
    ])
    .named(GSyntax::GenericArg)
}

pub fn generic_args_parser() -> Parser<GLang> {
    generic_arg_parser()
        .sep_by(just(GToken::Comma))
        .skip(GToken::Newline)
        .delim_by(just(GToken::LBracket), just(GToken::RBracket))
        .named(GSyntax::GenericArgs)
}

pub fn generics_parser() -> Parser<GLang> {
    type_parser()
        .sep_by(just(GToken::Comma))
        .delim_by(just(GToken::LBracket), just(GToken::RBracket))
}
