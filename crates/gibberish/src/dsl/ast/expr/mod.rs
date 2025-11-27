use crate::api::just::just;
use crate::api::ptr::ParserIndex;
use crate::dsl::ast::expr::call::CallAst;
use crate::dsl::ast::expr::choice::ChoiceAst;
use crate::dsl::ast::expr::ident::build_ident;
use crate::dsl::ast::expr::seq::SeqAst;
use crate::dsl::parser::ParserBuilder;
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

use gibberish_gibberish_parser::GibberishSyntax as S;
use gibberish_gibberish_parser::GibberishToken as T;

impl<'a> From<&'a Group<Gibberish>> for ExprAst<'a> {
    fn from(value: &'a Group<Gibberish>) -> Self {
        match value.kind {
            S::Named => ExprAst::Ident(value.lexeme_by_kind(T::Ident).unwrap()),
            S::Seq => ExprAst::Seq(SeqAst(value)),
            S::Choice => ExprAst::Choice(ChoiceAst(value)),
            S::MemberCall => ExprAst::Call(CallAst(value)),
            kind => panic!("Unexpected kind for expr: {kind}"),
        }
    }
}

impl<'a> ExprAst<'a> {
    pub fn build(&self, builder: &mut ParserBuilder) -> ParserIndex {
        match self {
            ExprAst::Ident(lexeme) => build_ident(builder, lexeme),
            ExprAst::Seq(seq_ast) => seq_ast.build(builder),
            ExprAst::Choice(choice_ast) => choice_ast.build(builder),
            ExprAst::Call(member_ast) => member_ast.build(builder),
        }
    }
}
