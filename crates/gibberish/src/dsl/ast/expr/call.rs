use gibberish_core::node::{Group, Lexeme};
use gibberish_gibberish_parser::{Gibberish, GibberishSyntax as S, GibberishToken as T};

use crate::{
    api::{Parser, ptr::ParserIndex},
    dsl::ast::{builder::ParserBuilder, expr::ExprAst},
};

#[derive(Clone, Copy)]
pub struct CallAst<'a>(pub &'a Group<Gibberish>);

impl<'a> CallAst<'a> {
    pub fn target(&self) -> ExprAst<'a> {
        self.0.green_children().next().unwrap().into()
    }

    pub fn arms(&self) -> impl Iterator<Item = CallArmAst<'a>> {
        self.0.green_children().filter_map(|it| {
            if it.kind == S::Call {
                Some(CallArmAst(it))
            } else {
                None
            }
        })
    }

    pub fn build(&self, builder: &mut ParserBuilder) -> ParserIndex {
        let mut expr = self.target().build(builder);
        for member in self.arms() {
            match member.name().text.as_str() {
                "repeated" => {
                    let args = member
                        .args()
                        .map(|it| it.build(builder))
                        .collect::<Vec<_>>();
                    if !args.is_empty() {
                        panic!("'repeated' expected no args but {} were found", args.len())
                    }
                    expr = expr.repeated(&mut builder.cache)
                }
                "sep_by" => {
                    let args = member
                        .args()
                        .map(|it| it.build(builder))
                        .collect::<Vec<_>>();
                    if args.len() != 1 {
                        panic!("'sep_by' expected one arg but {} were found", args.len())
                    }
                    expr = expr.sep_by(args[0].clone(), &mut builder.cache)
                }
                "sep_by_padded" => {
                    let args = member
                        .args()
                        .map(|it| it.build(builder))
                        .collect::<Vec<_>>();
                    if args.len() != 1 {
                        panic!(
                            "'sep_by_padded' expected one arg but {} were found",
                            args.len()
                        )
                    }
                    expr = expr.sep_by_extra(args[0].clone(), &mut builder.cache)
                }
                "delim_by" => {
                    let args = member
                        .args()
                        .map(|it| it.build(builder))
                        .collect::<Vec<_>>();
                    if args.len() != 2 {
                        panic!("'delim_by' expected 2 args but {} were found", args.len())
                    }
                    expr = expr.delim_by(args[0].clone(), args[1].clone(), &mut builder.cache)
                }
                "skip" => {
                    let args = member
                        .args()
                        .map(|it| it.build(builder))
                        .collect::<Vec<_>>();
                    if args.len() != 1 {
                        panic!("'skip' expected 1 arg but {} were found", args.len())
                    }
                    if let Parser::Just(tok) = args[0].get_ref(&builder.cache) {
                        expr = expr.skip(tok.0, &mut builder.cache)
                    } else {
                        panic!("Expected a token but found a parser")
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
                    if let Parser::Just(tok) = args[0].get_ref(&builder.cache) {
                        expr = expr.unskip(tok.0, &mut builder.cache)
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
                    expr = expr.or_not(&mut builder.cache);
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
            .green_node_by_name(S::CallName)
            .unwrap()
            .lexeme_by_kind(T::Ident)
            .unwrap()
    }

    pub fn args(&self) -> impl Iterator<Item = ExprAst<'a>> {
        let ret: Box<dyn Iterator<Item = ExprAst<'a>>> =
            if let Some(args) = self.0.green_node_by_name(S::Args) {
                Box::new(args.green_children().map(ExprAst::from))
            } else {
                Box::new(std::iter::empty())
            };
        ret
    }
}
