use crate::{
    api::{Parser, just::just, rec::recursive},
    giblang::{lang::GLang, lexer::GToken, parser::qualified_name, syntax::GSyntax},
};

pub fn pattern_parser() -> Parser<GLang> {
    recursive(|pat| {
        let tuple = pat
            .clone()
            .sep_by(just(GToken::Comma))
            .or_not()
            .skip(GToken::Newline)
            .delim_by(just(GToken::LParen), just(GToken::RParen))
            .named(GSyntax::Tuple);
        let struct_fields = just(GToken::Ident)
            .then(just(GToken::Colon))
            .then(pat)
            .sep_by(just(GToken::Comma))
            .or_not()
            .skip(GToken::Newline)
            .delim_by(just(GToken::LBrace), just(GToken::RBrace))
            .named(GSyntax::Tuple);
        qualified_name()
            .then(struct_fields.or(tuple.clone()).or_not())
            .or(tuple)
            .named(GSyntax::Pattern)
    })
}
