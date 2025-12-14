use gibberish_core::node::{Group, Lexeme};
use gibberish_gibberish_parser::{Gibberish, GibberishSyntax as S, GibberishToken as T};

use crate::{
    ast::{builder::ParserBuilder, expr::ExprAst},
    parser::{Parser, seq::seq},
};

#[derive(Clone, Copy)]
pub struct CallAst<'a>(pub &'a Group<Gibberish>);

impl<'a> CallAst<'a> {
    pub fn target(&self) -> ExprAst<'a> {
        self.0.groups().next().unwrap().into()
    }

    pub fn arms(&self) -> impl Iterator<Item = CallArmAst<'a>> {
        self.0.groups().filter_map(|it| {
            if it.kind == S::Call {
                Some(CallArmAst(it))
            } else {
                None
            }
        })
    }

    pub fn build(&self, builder: &mut ParserBuilder) -> Parser {
        let mut expr = self.target().build(builder);
        for member in self.arms() {
            let span = &member.name().span;
            match member.name().text.as_str() {
                "repeated" => {
                    let args = member
                        .args()
                        .map(|it| it.build(builder))
                        .collect::<Vec<_>>();
                    if !args.is_empty() {
                        builder.error(
                            &format!("'repeated' expected no args but {} were found", args.len()),
                            span.clone(),
                        );
                    }
                    expr = expr.repeated()
                }
                "sep_by" => {
                    let args = member
                        .args()
                        .map(|it| it.build(builder))
                        .collect::<Vec<_>>();
                    if args.len() != 1 {
                        builder.error(
                            &format!("'sep_by' expected one arg but {} were found", args.len()),
                            span.clone(),
                        );
                        panic!()
                    }
                    expr = expr.sep_by(args[0].clone())
                }
                "delim_by" => {
                    let args = member
                        .args()
                        .map(|it| it.build(builder))
                        .collect::<Vec<_>>();
                    if args.len() != 2 {
                        builder.error(
                            &format!("'delim_by' expected 2 args but {} were found", args.len()),
                            span.clone(),
                        )
                    }
                    expr = seq(vec![args[0].clone(), expr, args[1].clone()]);
                }
                "skip" => {
                    let args = member
                        .args()
                        .map(|it| it.build(builder))
                        .collect::<Vec<_>>();
                    if args.len() != 1 {
                        builder.error(
                            &format!("'skip' expected 1 arg but {} were found", args.len()),
                            span.clone(),
                        )
                    }
                    if let Parser::Just(tok) = args[0].clone() {
                        expr = expr.skip(tok.0)
                    } else {
                        builder.error("Expected a token but found a parser", span.clone())
                    }
                }
                "unskip" => {
                    let args = member
                        .args()
                        .map(|it| it.build(builder))
                        .collect::<Vec<_>>();
                    if args.len() != 1 {
                        panic!("'unskip' expected 1 arg but {} were found", args.len())
                    }
                    if let Parser::Just(tok) = args[0].clone() {
                        expr = expr.unskip(tok.0)
                    } else {
                        panic!("Expected a token but found a parser")
                    }
                }
                "or_not" => {
                    let args = member
                        .args()
                        .map(|it| it.build(builder))
                        .collect::<Vec<_>>();
                    if !args.is_empty() {
                        panic!("'or_not' expected 0 arg but {} were found", args.len())
                    }
                    expr = expr.or_not();
                }
                "rename" => {
                    let args = member.args().collect::<Vec<_>>();
                    if args.len() != 1 {
                        panic!("'rename' expected 0 arg but {} were found", args.len())
                    }
                    let ExprAst::Ident(lexeme) = args[0] else {
                        panic!("Expected an ident");
                    };
                    let Some(name) = builder.vars.iter().position(|it| it.0 == lexeme.text) else {
                        panic!("Parser not found '{}'", lexeme.text);
                    };
                    expr = expr.rename(lexeme.text.clone());
                }
                name => builder.error(
                    &format!("Function not found '{name}'"),
                    member.name().span.clone(),
                ),
            }
        }
        expr
    }
}

#[derive(Clone, Copy)]
pub struct CallArmAst<'a>(pub &'a Group<Gibberish>);

impl<'a> CallArmAst<'a> {
    pub fn name(&self) -> &'a Lexeme<Gibberish> {
        self.0
            .group_by_kind(S::CallName)
            .unwrap()
            .token_by_kind(T::Ident)
            .unwrap()
    }

    pub fn args(&self) -> impl Iterator<Item = ExprAst<'a>> {
        let ret: Box<dyn Iterator<Item = ExprAst<'a>>> =
            if let Some(args) = self.0.group_by_kind(S::Args) {
                Box::new(args.groups().map(ExprAst::from))
            } else {
                Box::new(std::iter::empty())
            };
        ret
    }
}
