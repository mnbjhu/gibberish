use crate::{
    api::{Parser, just::just, seq::seq},
    giblang::{
        lang::GLang, lexer::GToken, parser::decl::struct_::struct_body_parser, syntax::GSyntax,
    },
};

pub fn enum_parser() -> Parser<GLang> {
    let member = seq(vec![
        just(GToken::Ident).named(GSyntax::Name),
        struct_body_parser(),
    ])
    .named(GSyntax::Member);
    seq(vec![
        just(GToken::Enum),
        just(GToken::Ident).named(GSyntax::TypeName),
        member
            .sep_by(just(GToken::Comma))
            .skip(GToken::Newline)
            .delim_by(just(GToken::LBrace), just(GToken::RBrace)),
    ])
    .named(GSyntax::Enum)
}
