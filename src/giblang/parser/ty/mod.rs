use crate::{
    api::{Parser, just::just, rec::recursive, seq::seq},
    giblang::{lang::GLang, lexer::GToken, syntax::GSyntax},
};

pub mod generic_arg;

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
