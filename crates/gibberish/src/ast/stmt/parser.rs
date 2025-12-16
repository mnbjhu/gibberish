use gibberish_core::node::{Group, Lexeme};
use gibberish_gibberish_parser::{Gibberish, GibberishToken};

use crate::ast::{builder::ParserBuilder, expr::ExprAst};

#[derive(Clone, Copy)]
pub struct ParserDefAst<'a>(pub &'a Group<Gibberish>);

impl<'a> ParserDefAst<'a> {
    pub fn name(&self) -> &'a Lexeme<Gibberish> {
        self.0.token_by_kind(GibberishToken::Ident).unwrap()
    }

    pub fn expr(&self) -> Option<ExprAst<'a>> {
        self.0.groups().next().map(ExprAst::from)
    }

    pub fn build(&self, builder: &mut ParserBuilder) {
        let name = self.name().text.as_str();
        if let Some(expr) = self.expr() {
            let mut p = expr.build(builder);
            if !name.starts_with("_") {
                p = p.named(name.to_string());
            }
            let index = builder.vars.iter().position(|(it, _)| it == name).unwrap();
            builder.vars[index] = (name.to_string(), p.clone());
        }
    }
}
