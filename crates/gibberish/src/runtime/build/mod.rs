use std::collections::HashMap;

use crate::{
    ast::RootAst,
    runtime::{lexer::Lexer, parser::Parser},
};

mod expr;
mod stmt;

#[derive(Default)]
pub struct RuntimeBuilder {
    pub lexer: Lexer,
    // TODO: Actual implementation will need to build recursize structures
    pub parsers: HashMap<String, Parser>,
}

impl RuntimeBuilder {
    pub fn get_parser(&self, name: &str) -> Parser {
        if let Some(p) = self.parsers.get(name) {
            p.clone()
        } else {
            self.lexer.get_parser(name).expect(&format!(
                "Not doing real errors rn but '{name}' wasn't found"
            ))
        }
    }
}

impl<'a> RootAst<'a> {
    pub fn build_runtime(&self, builder: &mut RuntimeBuilder) {
        for stmt in self.stmts() {
            stmt.build_runtime(builder)
        }
    }
}
