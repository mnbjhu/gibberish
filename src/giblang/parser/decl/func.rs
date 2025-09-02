use crate::{
    api::{Parser, just::just, maybe::Requirement, seq::seq},
    giblang::{
        lang::GLang,
        lexer::GToken,
        parser::{
            stmt::stmt_parser,
            ty::{generic_arg::generic_args_parser, type_parser},
        },
        syntax::GSyntax,
    },
};

pub fn func_parser() -> Parser<GLang> {
    let func_arg = seq(vec![
        just(GToken::Ident),
        just(GToken::Colon),
        type_parser(),
    ])
    .named(GSyntax::Param);

    seq(vec![
        just(GToken::Fn),
        just(GToken::Ident).named(GSyntax::Name),
        generic_args_parser().or_not(),
        func_arg
            .sep_by(just(GToken::Comma))
            .or_not()
            .skip(GToken::Newline)
            .delim_by(just(GToken::LParen), just(GToken::RParen))
            .named(GSyntax::Params),
        stmt_parser()
            .sep_by_extra(just(GToken::Semi), Requirement::No, Requirement::Maybe)
            .or_not()
            .skip(GToken::Newline)
            .delim_by(just(GToken::LBrace), just(GToken::RBrace))
            .named(GSyntax::CodeBlock),
    ])
    .named(GSyntax::Function)
}
