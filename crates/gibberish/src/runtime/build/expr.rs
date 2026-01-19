use crate::{
    ast::expr::ExprAst,
    runtime::{
        build::RuntimeBuilder,
        parser::{
            Parser,
            api::{choice::Choice, rep::Rep, seq::Seq},
        },
    },
};

impl<'a> ExprAst<'a> {
    pub fn build_runtime(&self, builder: &mut RuntimeBuilder) -> Parser {
        match self {
            ExprAst::Ident(lexeme) => builder.get_parser(&lexeme.text),
            ExprAst::Seq(seq_ast) => Parser::Seq(Seq(seq_ast
                .iter()
                .map(|it| it.build_runtime(builder))
                .collect())),
            ExprAst::Choice(choice_ast) => Parser::Choice(Choice(
                choice_ast
                    .iter()
                    .map(|it| it.build_runtime(builder))
                    .collect(),
            )),
            ExprAst::Bracketed(expr_ast, _) => expr_ast.build_runtime(builder),
            ExprAst::Empty => todo!(),
            ExprAst::Call(call) => {
                let mut expr = call.target().build_runtime(builder);
                for arm in call.arms() {
                    match arm.name().unwrap().text.as_str() {
                        "repeated" => expr = Parser::Rep(Rep(Box::new(expr))),
                        _ => todo!(),
                    }
                }
                expr
            }
        }
    }
}
