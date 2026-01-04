use crate::{
    ast::expr::ExprAst,
    runtime::{build::RuntimeBuilder, parser::Parser},
};

impl<'a> ExprAst<'a> {
    pub fn build_runtime(&self, builder: &mut RuntimeBuilder) -> Parser {
        match self {
            ExprAst::Ident(lexeme) => builder.get_parser(&lexeme.text),
            ExprAst::Seq(seq_ast) => {
                Parser::Seq(seq_ast.iter().map(|it| it.build_runtime(builder)).collect())
            }
            ExprAst::Choice(choice_ast) => Parser::Choice(
                choice_ast
                    .iter()
                    .map(|it| it.build_runtime(builder))
                    .collect(),
            ),
            ExprAst::Bracketed(expr_ast, _) => expr_ast.build_runtime(builder),
            ExprAst::Empty => todo!(),
            ExprAst::Call(_) => todo!(),
        }
    }
}
