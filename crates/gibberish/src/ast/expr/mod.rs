use crate::ast::CheckState;
use crate::ast::LspItem;
use crate::ast::LspNode;
use crate::ast::builder::ParserBuilder;
use crate::ast::expr::call::CallAst;
use crate::ast::expr::choice::ChoiceAst;
use crate::ast::expr::ident::build_ident;
use crate::ast::expr::seq::SeqAst;
use crate::parser::Parser;
use gibberish_core::node::Span;
use gibberish_core::node::{Group, Lexeme};
use gibberish_gibberish_parser::Gibberish;

pub mod call;
pub mod choice;
pub mod ident;
pub mod seq;

#[derive(Clone, Copy)]
pub enum ExprAst<'a> {
    Ident(&'a Lexeme<Gibberish>),
    Seq(SeqAst<'a>),
    Choice(ChoiceAst<'a>),
    Call(CallAst<'a>),
}

impl<'a> ExprAst<'a> {
    pub fn build(&self, builder: &mut ParserBuilder) -> Parser {
        match self {
            ExprAst::Ident(lexeme) => build_ident(builder, lexeme),
            ExprAst::Seq(seq_ast) => seq_ast.build(builder),
            ExprAst::Choice(choice_ast) => choice_ast.build(builder),
            ExprAst::Call(member_ast) => member_ast.build(builder),
        }
    }
}

use gibberish_gibberish_parser::GibberishSyntax as S;
use gibberish_gibberish_parser::GibberishToken as T;

impl<'a> From<&'a Group<Gibberish>> for ExprAst<'a> {
    fn from(value: &'a Group<Gibberish>) -> Self {
        match value.kind {
            S::Named => ExprAst::Ident(value.token_by_kind(T::Ident).unwrap()),
            S::Seq => ExprAst::Seq(SeqAst(value)),
            S::Choice => ExprAst::Choice(ChoiceAst(value)),
            S::MemberCall => ExprAst::Call(CallAst(value)),
            kind => panic!("Unexpected kind for expr: {kind}"),
        }
    }
}

impl<'a> LspItem<'a> for ExprAst<'a> {
    fn at(&self, offset: usize) -> Option<LspNode<'a>> {
        match self {
            ExprAst::Ident(lexeme) => {
                if lexeme.span.contains(&offset) {
                    Some(LspNode::Expr(*self))
                } else {
                    None
                }
            }
            ExprAst::Seq(seq_ast) => seq_ast.iter().find_map(|it| it.at(offset)),
            ExprAst::Choice(choice_ast) => choice_ast.iter().find_map(|it| it.at(offset)),
            ExprAst::Call(call_ast) => {
                if let Some(target) = call_ast.target().at(offset) {
                    Some(target)
                } else {
                    call_ast.arms().find_map(|it| it.at(offset))
                }
            }
        }
    }
}

impl<'a> ExprAst<'a> {
    pub fn check(&self, state: &mut CheckState<'a>) {
        match self {
            ExprAst::Ident(lexeme) => {
                state.refs.push(Lexeme::clone(lexeme));
            }
            ExprAst::Seq(seq_ast) => seq_ast.iter().for_each(|it| it.check(state)),
            ExprAst::Choice(choice_ast) => choice_ast.iter().for_each(|it| it.check(state)),
            ExprAst::Call(call_ast) => call_ast.check(state),
        }
    }

    pub fn span(&self) -> Span {
        match self {
            ExprAst::Ident(lexeme) => lexeme.span.clone(),
            ExprAst::Seq(s) => s.0.span(),
            ExprAst::Choice(c) => c.0.span(),
            ExprAst::Call(c) => c.0.span(),
        }
    }
}
