use gibberish_core::node::{Group, Lexeme};
use gibberish_gibberish_parser::{Gibberish, GibberishToken};

use crate::dsl::ast::builder::ParserBuilder;

#[derive(Clone, Copy)]
pub struct KeywordDefAst<'a>(pub &'a Group<Gibberish>);

impl<'a> KeywordDefAst<'a> {
    pub fn name(&self) -> &'a Lexeme<Gibberish> {
        self.0.lexeme_by_kind(GibberishToken::Ident).unwrap()
    }

    pub fn build(&self, builder: &mut ParserBuilder) {
        let regex = format!("({})[^_a-zA-Z0-9]", self.name().text);
        builder.lexer.push((self.name().text.to_string(), regex));
    }
}
