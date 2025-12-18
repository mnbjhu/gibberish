use gibberish_core::node::{Group, Lexeme};
use gibberish_gibberish_parser::{Gibberish, GibberishToken};

use crate::{
    ast::{LspItem, LspNode, builder::ParserBuilder, expr::ExprAst, stmt::StmtAst},
    lexer::{RegexAst, seq::parse_seq},
};

#[derive(Clone, Copy)]
pub struct TokenDefAst<'a>(pub &'a Group<Gibberish>);

impl<'a> TokenDefAst<'a> {
    pub fn name(&self) -> Option<&'a Lexeme<Gibberish>> {
        self.0.token_by_kind(GibberishToken::Ident)
    }

    pub fn value(&self) -> Option<&'a Lexeme<Gibberish>> {
        self.0.token_by_kind(GibberishToken::String)
    }

    pub fn build(&self, builder: &mut ParserBuilder) {
        let Some(value) = self.value() else { return };
        let mut text = value.text.clone();
        text.remove(0);
        text.pop();
        text = text.replace("\\\\", "\\");
        text = text.replace("\\\"", "\"");
        text = text.replace("\\n", "\n");
        text = text.replace("\\t", "\t");
        text = text.replace("\\f", "\x0C");
        let regex = parse_seq(&text, &mut 0);
        if let Some(regex) = regex {
            builder
                .lexer
                .push((self.name().unwrap().text.to_string(), regex));
        } else {
            builder.error("Failed to parse regex", value.span.clone());
            builder
                .lexer
                .push((self.name().unwrap().text.to_string(), RegexAst::Error));
        }
    }
}

impl<'a> LspItem<'a> for TokenDefAst<'a> {
    fn at(&self, offset: usize) -> Option<LspNode<'a>> {
        if self.0.span().contains(&offset) {
            if let Some(name) = self.name()
                && name.span.contains(&offset)
            {
                Some(LspNode::Expr(ExprAst::Ident(name)))
            } else {
                Some(LspNode::Stmt(StmtAst::Token(*self)))
            }
        } else {
            None
        }
    }
}
