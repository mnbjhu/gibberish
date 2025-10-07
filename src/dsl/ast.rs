use std::iter::empty;

use crate::{
    dsl::lang::{DslLang, DslSyntax as S, DslToken as T},
    parser::node::{Group, Lexeme},
};

#[derive(Clone, Copy)]
pub struct RootAst<'a>(pub &'a Group<DslLang>);

impl<'a> RootAst<'a> {
    pub fn iter(&self) -> impl Iterator<Item = AssignmentAst<'a>> {
        self.0.green_children().map(AssignmentAst)
    }
}

#[derive(Clone, Copy)]
pub struct AssignmentAst<'a>(pub &'a Group<DslLang>);

impl<'a> AssignmentAst<'a> {
    pub fn name(&self) -> &'a Lexeme<DslLang> {
        self.0.lexeme_by_kind(T::Ident).unwrap()
    }

    pub fn expr(&self) -> AssignableAst<'a> {
        if let Some(l) = self.0.lexeme_by_kind(T::String) {
            AssignableAst::Token(l)
        } else if let Some(g) = self.0.green_children().next() {
            AssignableAst::Expr(g.into())
        } else {
            AssignableAst::Missing
        }
    }
}

#[derive(Clone, Copy)]
pub enum AssignableAst<'a> {
    Missing,
    Token(&'a Lexeme<DslLang>),
    Expr(ExprAst<'a>),
}

#[derive(Clone, Copy)]
pub enum ExprAst<'a> {
    Ident(&'a Lexeme<DslLang>),
    Seq(SeqAst<'a>),
    Choice(ChoiceAst<'a>),
    Call(CallAst<'a>),
}

impl<'a> From<&'a Group<DslLang>> for ExprAst<'a> {
    fn from(value: &'a Group<DslLang>) -> Self {
        match value.kind {
            S::Name => ExprAst::Ident(value.lexeme_by_kind(T::Ident).unwrap()),
            S::Seq => ExprAst::Seq(SeqAst(value)),
            S::Choice => ExprAst::Choice(ChoiceAst(value)),
            S::Call => ExprAst::Call(CallAst(value)),
            _ => panic!(),
        }
    }
}

#[derive(Clone, Copy)]
pub struct SeqAst<'a>(pub &'a Group<DslLang>);

impl<'a> SeqAst<'a> {
    pub fn iter(&self) -> impl Iterator<Item = ExprAst<'a>> {
        self.0.green_children().map(ExprAst::from)
    }
}

#[derive(Clone, Copy)]
pub struct ChoiceAst<'a>(pub &'a Group<DslLang>);

impl<'a> ChoiceAst<'a> {
    pub fn iter(&self) -> impl Iterator<Item = ExprAst<'a>> {
        self.0.green_children().map(ExprAst::from)
    }
}

#[derive(Clone, Copy)]
pub struct CallAst<'a>(pub &'a Group<DslLang>);

impl<'a> CallAst<'a> {
    pub fn name(&self) -> &'a Lexeme<DslLang> {
        self.0
            .green_node_by_name(S::Name)
            .unwrap()
            .lexeme_by_kind(T::Ident)
            .unwrap()
    }
    pub fn args(&self) -> impl Iterator<Item = ExprAst<'a>> {
        let ret: Box<dyn Iterator<Item = ExprAst<'a>>> =
            if let Some(args) = self.0.green_node_by_name(S::Args) {
                Box::new(args.green_children().map(ExprAst::from))
            } else {
                Box::new(empty())
            };
        self.0.green_children().map(ExprAst::from)
    }
}
