use gibberish_core::node::{Group, Lexeme};
use gibberish_gibberish_parser::{Gibberish, GibberishSyntax as S, GibberishToken as T};

use crate::{
    ast::{CheckState, LspItem, LspNode, builder::ParserBuilder, expr::ExprAst},
    lsp::funcs::DEFAULT_FUNCS,
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
    pub fn check(&self, state: &mut CheckState<'a>) {
        self.target().check(state);
        self.arms().for_each(|it| it.check(state))
    }

    pub fn build(&self, builder: &mut ParserBuilder) -> Parser {
        let mut expr = self.target().build(builder);
        for member in self.arms() {
            let span = &member.name().unwrap().span;
            match member.name().unwrap().text.as_str() {
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
                    if !builder.vars.iter().any(|it| it.0 == lexeme.text) {
                        panic!("Parser not found '{}'", lexeme.text);
                    };
                    expr = expr.rename(lexeme.text.clone());
                }
                name => builder.error(
                    &format!("Function not found '{name}'"),
                    member.name().unwrap().span.clone(),
                ),
            }
        }
        expr
    }
}

#[derive(Clone, Copy)]
pub struct CallArmAst<'a>(pub &'a Group<Gibberish>);

impl<'a> CallArmAst<'a> {
    pub fn name(&self) -> Option<&'a Lexeme<Gibberish>> {
        self.0
            .group_by_kind(S::CallName)
            .map(|it| it.token_by_kind(T::Ident).unwrap())
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

    pub fn check(&self, state: &mut CheckState<'a>) {
        if let Some(name) = self.name() {
            if let Some(expected) = DEFAULT_FUNCS.iter().find(|it| it.name == name.text) {
                state.func_calls.push(name.span.clone());
                let args_len = self.args().count();
                for (index, arg) in self.args().enumerate() {
                    if index >= expected.args.len() {
                        state.error("This argument is unexpected".to_string(), arg.span());
                    }
                }
                if args_len < expected.args.len() {
                    state.error(
                        format!("Missing arguments: {}", expected.args[args_len..].join(",")),
                        name.span.clone(),
                    );
                }
            } else {
                state.error(
                    format!("Function '{}' not found", name.text),
                    name.span.clone(),
                );
            }
        }

        self.args().for_each(|it| it.check(state));
    }
}

impl<'a> LspItem<'a> for CallArmAst<'a> {
    fn at(&self, offset: usize) -> Option<crate::ast::LspNode<'a>> {
        if self.0.span().contains(&offset) {
            if let Some(name) = self.name()
                && name.span.contains(&offset)
            {
                Some(LspNode::FunctionName(name))
            } else {
                self.args().find_map(|it| it.at(offset))
            }
        } else {
            None
        }
    }
}
