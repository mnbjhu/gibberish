use gibberish_core::node::{Group, Lexeme};
use gibberish_gibberish_parser::{Gibberish, GibberishToken};

use crate::{
    ast::{builder::ParserBuilder, expr::ExprAst},
    parser::{Parser, ptr::ParserIndex},
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

    pub fn build(&self, builder: &mut ParserBuilder) -> ParserIndex {
        let name = self.name().text.as_str();
        let name_index = builder.vars.len();
        if let Some(expr) = self.expr() {
            let mut p = expr.build(builder);
            if !name.starts_with("_") {
                p = p.named(name_index as u32, &mut builder.cache);
            }
            if builder.replace_var(name, p.clone()) {
                p
            } else {
                builder.vars.push((name.to_string(), p.clone()));
                p
            }
        } else {
            let empty = Parser::Empty.cache(&mut builder.cache);
            builder.vars.push((name.to_string(), empty.clone()));
            empty
        }
    }
}
