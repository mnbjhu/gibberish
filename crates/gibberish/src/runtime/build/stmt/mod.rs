use crate::{
    ast::stmt::{
        StmtAst,
        parser::ParserDefAst,
        token::{TokenDefAst, parse_string},
    },
    lexer::{RegexAst, seq::parse_seq},
    runtime::{build::RuntimeBuilder, lexer::LexerToken, parser::Parser},
};

impl<'a> StmtAst<'a> {
    pub fn build_runtime(&self, builder: &mut RuntimeBuilder) {
        match self {
            StmtAst::Token(t) => t.build_runtime(builder),
            StmtAst::Parser(p) => p.build_runtime(builder),
            StmtAst::Keyword(k) => todo!(),
            StmtAst::Fold(f) => todo!(),
        }
    }
}

impl<'a> TokenDefAst<'a> {
    pub fn build_runtime(&self, builder: &mut RuntimeBuilder) {
        let name = self.name().unwrap().text.to_string();
        let regex = parse_seq(&parse_string(&self.value().unwrap().text), &mut 0)
            .unwrap_or_else(|| panic!("Failed to parse regex '{}'", &self.value().unwrap().text));
        builder.lexer.tokens.push(LexerToken {
            id: builder.lexer.tokens.len() as u32,
            name,
            regex,
        });
    }
}
impl<'a> ParserDefAst<'a> {
    pub fn build_runtime(&self, builder: &mut RuntimeBuilder) {
        let name = self.name().unwrap().text.to_string();
        let expr = self.expr().unwrap().build_runtime(builder);
        builder
            .named
            .insert(builder.parsers.len() as u32, name.clone());
        let expr = if name.starts_with("_") {
            expr
        } else {
            Parser::Named {
                name: builder.parsers.len() as u32,
                inner: Box::new(expr),
            }
        };
        builder.parsers.insert(name, expr);
    }
}
