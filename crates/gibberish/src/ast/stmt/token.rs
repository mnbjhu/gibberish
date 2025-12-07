use gibberish_core::node::{Group, Lexeme};
use gibberish_gibberish_parser::{Gibberish, GibberishToken};

use crate::{
    ast::builder::ParserBuilder,
    lexer::{RegexAst, seq::parse_seq},
};

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
        let Some(value) = self.value() else { return };
        let text = rust_string(&value.text);
        let regex = parse_seq(&text, &mut 0);
        if let Some(regex) = regex {
            builder.lexer.push((self.name().text.to_string(), regex));
        } else {
            builder.error("Failed to parse regex", value.span.clone());
            builder
                .lexer
                .push((self.name().text.to_string(), RegexAst::Error));
        }
    }
}

pub fn rust_string(value: &str) -> String {
    let mut text = value.to_string();
    text.remove(0);
    text.pop();
    text = text.replace("\\\\", "\\");
    text = text.replace("\\\"", "\"");
    text = text.replace("\\n", "\n");
    text = text.replace("\\t", "\t");
    text = text.replace("\\f", "\x0C");
    text
}
