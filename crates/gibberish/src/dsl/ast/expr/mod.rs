use std::iter::empty;

use gibberish_gibberish_parser::Gibberish;
use gibberish_tree::node::{Group, Lexeme};

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

#[derive(Clone, Copy)]
pub struct SeqAst<'a>(pub &'a Group<Gibberish>);

impl<'a> SeqAst<'a> {
    pub fn iter(&self) -> impl Iterator<Item = ExprAst<'a>> {
        self.0.green_children().map(ExprAst::from)
    }
}

#[derive(Clone, Copy)]
pub struct ChoiceAst<'a>(pub &'a Group<Gibberish>);

impl<'a> ChoiceAst<'a> {
    pub fn iter(&self) -> impl Iterator<Item = ExprAst<'a>> {
        self.0.green_children().map(ExprAst::from)
    }
}

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
                Box::new(empty())
            };
        ret
    }
}
