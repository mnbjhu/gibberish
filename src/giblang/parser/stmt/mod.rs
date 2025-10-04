use crate::{
    api::{Parser, choice::choice, just::just, rec::recursive, seq::seq},
    giblang::{
        lang::GLang,
        lexer::GToken,
        parser::{expr::expr_parser, pattern::pattern_parser},
        syntax::GSyntax,
    },
};

pub fn stmt_parser() -> Parser<GLang> {
    recursive(|stmt| {
        let expr = expr_parser(stmt.clone());
        let let_ = seq(vec![
            just(GToken::Let),
            pattern_parser(),
            just(GToken::Eq),
            expr.clone().named(GSyntax::Value),
        ])
        .named(GSyntax::Assignment);
        choice(vec![let_, expr])
    })
}
