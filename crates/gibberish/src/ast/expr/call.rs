use std::collections::HashMap;

use gibberish_core::node::{Group, Lexeme};
use gibberish_gibberish_parser::{Gibberish, GibberishSyntax as S, GibberishToken as T};

use crate::{
    ast::{
        builder::ParserBuilder,
        expr::{
            ExprAst,
            arg::{ArgAst, NamedParamAst},
        },
    },
    parser::{Parser, ptr::ParserIndex},
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
            let span = &member.name().span;
            match member.name().text.as_str() {
                "repeated" => {
                    let args = member
                        .parser_args()
                        .map(|it| it.build(builder))
                        .collect::<Vec<_>>();
                    if !args.is_empty() {
                        builder.error(
                            &format!("'repeated' expected no args but {} were found", args.len()),
                            span.clone(),
                        );
                    }
                    expr = expr.repeated(&mut builder.cache)
                }
                "sep_by" => {
                    let args = member
                        .parser_args()
                        .map(|it| it.build(builder))
                        .collect::<Vec<_>>();
                    if args.len() != 1 {
                        builder.error(
                            &format!("'sep_by' expected one arg but {} were found", args.len()),
                            span.clone(),
                        );
                        panic!()
                    }
                    let named = member.named_args().collect::<HashMap<_, _>>();
                    let mut at_least = 1;
                    let at_least_value = named.get("at_least");
                    if let Some(at_least_value) = at_least_value {
                        if let StringOrInt::Int(at_least_value) = at_least_value {
                            at_least = *at_least_value
                        } else {
                            panic!("Expected an int")
                        }
                    }
                    expr = expr.sep_by_extra(args[0].clone(), at_least, &mut builder.cache)
                }
                "delim_by" => {
                    let args = member
                        .parser_args()
                        .map(|it| it.build(builder))
                        .collect::<Vec<_>>();
                    if args.len() != 2 {
                        builder.error(
                            &format!("'delim_by' expected 2 args but {} were found", args.len()),
                            span.clone(),
                        )
                    }
                    expr = expr.delim_by(args[0].clone(), args[1].clone(), &mut builder.cache)
                }
                "skip" => {
                    let args = member
                        .parser_args()
                        .map(|it| it.build(builder))
                        .collect::<Vec<_>>();
                    if args.len() != 1 {
                        builder.error(
                            &format!("'skip' expected 1 arg but {} were found", args.len()),
                            span.clone(),
                        )
                    }
                    if let Parser::Just(tok) = args[0].get_ref(&builder.cache) {
                        expr = expr.skip(tok.0, &mut builder.cache)
                    } else {
                        builder.error("Expected a token but found a parser", span.clone())
                    }
                }
                "unskip" => {
                    let args = member
                        .parser_args()
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
                        .parser_args()
                        .map(|it| it.build(builder))
                        .collect::<Vec<_>>();
                    if !args.is_empty() {
                        panic!("'or_not' expected 0 arg but {} were found", args.len())
                    }
                    expr = expr.or_not(&mut builder.cache);
                }
                "rename" => {
                    let args = member.parser_args().collect::<Vec<_>>();
                    if args.len() != 1 {
                        panic!("'rename' expected 0 arg but {} were found", args.len())
                    }
                    let ExprAst::Ident(lexeme) = args[0] else {
                        panic!("Expected an ident");
                    };
                    let Some(name) = builder.vars.iter().position(|it| it.0 == lexeme.text) else {
                        panic!("Parser not found '{}'", lexeme.text);
                    };
                    expr = expr.rename(name as u32, &mut builder.cache);
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
    pub fn args(&self) -> impl Iterator<Item = ArgAst<'a>> {
        let ret: Box<dyn Iterator<Item = ArgAst<'a>>> =
            if let Some(args) = self.0.green_node_by_name(S::Args) {
                Box::new(args.green_children().map(ArgAst::from))
            } else {
                Box::new(std::iter::empty())
            };
        ret
    }

    pub fn parser_args(&self) -> impl Iterator<Item = ExprAst<'a>> {
        self.args().filter_map(|it| match it {
            ArgAst::Expr(expr_ast) => Some(expr_ast),
            // ArgAst::Named(_) => None,
        })
    }

    pub fn named_args(&self) -> impl Iterator<Item = (String, StringOrInt)> {
        self.args().filter_map(|it| match it {
            ArgAst::Expr(_) => None,
            // ArgAst::Named(p) => p.value().map(|value| (p.name(), value)),
        })
    }
}

pub enum StringOrInt {
    String(String),
    Int(usize),
}
