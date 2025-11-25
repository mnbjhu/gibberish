use gibberish_gibberish_parser::{Gibberish, GibberishToken};
use gibberish_tree::node::{Group, Lexeme};

#[derive(Clone, Copy)]
pub struct KeywordDefAst<'a>(pub &'a Group<Gibberish>);

impl<'a> KeywordDefAst<'a> {
    pub fn name(&self) -> &'a Lexeme<Gibberish> {
        self.0.lexeme_by_kind(GibberishToken::Ident).unwrap()
    }
}
