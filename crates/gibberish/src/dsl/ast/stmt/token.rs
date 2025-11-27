use gibberish_core::node::{Group, Lexeme};
use gibberish_gibberish_parser::{Gibberish, GibberishToken};

use crate::dsl::ast::builder::ParserBuilder;

#[derive(Clone, Copy)]
pub struct TokenDefAst<'a>(pub &'a Group<Gibberish>);

impl<'a> TokenDefAst<'a> {
    pub fn name(&self) -> &'a Lexeme<Gibberish> {
        self.0.lexeme_by_kind(GibberishToken::Ident).unwrap()
    }

    pub fn value(&self) -> Option<&'a Lexeme<Gibberish>> {
        self.0.lexeme_by_kind(GibberishToken::String)
    }

    pub fn build(&self, builder: &mut ParserBuilder) {
        let value = self.value().unwrap();
        let mut text = value.text.clone();
        text.remove(0);
        text.pop();
        text = text.replace("\\\\", "\\");
        text = text.replace("\\\"", "\"");
        text = text.replace("\\n", "\n");
        text = text.replace("\\t", "\t");
        text = text.replace("\\f", "\x0C");
        builder.lexer.push((self.name().text.to_string(), text));
    }
}
