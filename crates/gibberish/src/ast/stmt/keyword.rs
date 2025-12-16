use gibberish_core::node::{Group, Lexeme};
use gibberish_gibberish_parser::{Gibberish, GibberishToken};

use crate::{
    ast::builder::ParserBuilder,
    lexer::{RegexAst, option::OptionAst},
};

#[derive(Clone, Copy)]
pub struct KeywordDefAst<'a>(pub &'a Group<Gibberish>);

impl<'a> KeywordDefAst<'a> {
    pub fn name(&self) -> &'a Lexeme<Gibberish> {
        self.0.token_by_kind(GibberishToken::Ident).unwrap()
    }

    pub fn build(&self, builder: &mut ParserBuilder) {
        builder.lexer.push((
            self.name().text.to_string(),
            RegexAst::Seq(vec![
                RegexAst::Group {
                    options: vec![RegexAst::Exact(self.name().text.clone())],
                    capture: true,
                },
                RegexAst::Choice {
                    negate: true,
                    options: vec![
                        OptionAst::Range(b'a'..b'z'),
                        OptionAst::Range(b'A'..b'Z'),
                        OptionAst::Range(b'0'..b'9'),
                        OptionAst::Char(b'_'),
                    ],
                },
            ]),
        ));
    }
}
