use gibberish_core::node::Lexeme;
use gibberish_gibberish_parser::Gibberish;

use crate::{
    api::{just::just, ptr::ParserIndex},
    dsl::ast::builder::ParserBuilder,
};

pub fn build_ident(builder: &mut ParserBuilder, lexeme: &Lexeme<Gibberish>) -> ParserIndex {
    if let Some(p) = builder
        .vars
        .iter()
        .find(|it| it.0 == lexeme.text)
        .map(|it| it.1.clone())
    {
        p
    } else {
        let tok = builder
            .lexer
            .iter()
            .position(|(name, _)| name == &lexeme.text);
        if tok.is_none() {
            builder.error("Name not found", lexeme.span.clone());
            panic!("Unable to build parser")
        }
        just(tok.unwrap() as u32, &mut builder.cache)
    }
}
