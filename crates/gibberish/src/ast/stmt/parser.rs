use gibberish_core::node::{Group, Lexeme};
use gibberish_gibberish_parser::{Gibberish, GibberishToken};

use crate::{
    ast::{builder::ParserBuilder, expr::ExprAst},
    parser::Parser,
};

#[derive(Clone, Copy)]
pub struct ParserDefAst<'a>(pub &'a Group<Gibberish>);

impl<'a> ParserDefAst<'a> {
    pub fn name(&self) -> &'a Lexeme<Gibberish> {
        self.0.token_by_kind(GibberishToken::Ident).unwrap()
    }

    pub fn expr(&self) -> Option<ExprAst<'a>> {
        self.0.groups().next().map(ExprAst::from)
    }

    pub fn build(&self, builder: &mut ParserBuilder) -> Parser {
        let name = self.name().text.as_str();
        if let Some(expr) = self.expr() {
            let mut p = expr.build(builder);
            if !name.starts_with("_") {
                p = p.named(name.to_string());
            }
            builder.vars.push((name.to_string(), p.clone()));
            p
        } else {
            let empty = Parser::Empty;
            builder.vars.push((name.to_string(), empty.clone()));
            empty
        }
    }
}
