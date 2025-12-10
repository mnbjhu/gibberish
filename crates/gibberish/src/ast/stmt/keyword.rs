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
        self.0.lexeme_by_kind(GibberishToken::Ident).unwrap()
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
                        OptionAst::Range('a' as u8..'z' as u8),
                        OptionAst::Range('A' as u8..'Z' as u8),
                        OptionAst::Range('0' as u8..'9' as u8),
                        OptionAst::Char('_' as u8),
                    ],
                },
            ]),
        ));
    }
}
