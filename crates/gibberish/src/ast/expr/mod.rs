use crate::ast::CheckState;
use crate::ast::LspItem;
use crate::ast::LspNode;
use crate::ast::builder::ParserBuilder;
use crate::ast::expr::call::CallAst;
use crate::ast::expr::choice::ChoiceAst;
use crate::ast::expr::choice::INDENT;
use crate::ast::expr::ident::build_ident;
use crate::ast::expr::seq::SeqAst;
use crate::ast::stmt::StmtAst;
use crate::lsp::funcs::Type;
use crate::parser::Parser;
use gibberish_core::node::Span;
use gibberish_core::node::{Group, Lexeme};
use gibberish_gibberish_parser::Gibberish;

pub mod call;
pub mod choice;
pub mod ident;
pub mod seq;

#[derive(Clone)]
pub enum ExprAst<'a> {
    Ident(&'a Lexeme<Gibberish>),
    Seq(SeqAst<'a>),
    Choice(ChoiceAst<'a>),
    Call(CallAst<'a>),
    Bracketed(Box<ExprAst<'a>>, &'a Group<Gibberish>),
    Empty,
}

impl<'a> ExprAst<'a> {
    pub fn build(&self, builder: &mut ParserBuilder) -> Parser {
        match self {
            ExprAst::Ident(lexeme) => build_ident(builder, lexeme),
            ExprAst::Seq(seq_ast) => seq_ast.build(builder),
            ExprAst::Choice(choice_ast) => choice_ast.build(builder),
            ExprAst::Call(member_ast) => member_ast.build(builder),
            ExprAst::Bracketed(expr, _) => expr.build(builder),
            ExprAst::Empty => panic!("Can't build missing expr"),
        }
    }

    pub fn pretty_inner<'b, D, A>(self, allocator: &'b D) -> DocBuilder<'b, D, A>
    where
        D: DocAllocator<'b, A>,
        D::Doc: Clone,
        A: Clone,
        'a: 'b,
    {
        match self {
            ExprAst::Ident(lexeme) => allocator.text(&lexeme.text),
            ExprAst::Seq(seq) => seq.pretty(allocator),
            ExprAst::Choice(choice) => choice.pretty(allocator),
            ExprAst::Call(call) => call.pretty(allocator),
            ExprAst::Bracketed(_, _) => self.pretty(allocator),
            ExprAst::Empty => todo!(),
        }
    }

    pub fn pretty<'b, D, A>(self, allocator: &'b D) -> DocBuilder<'b, D, A>
    where
        D: DocAllocator<'b, A>,
        D::Doc: Clone,
        A: Clone,
        'a: 'b,
    {
        if let ExprAst::Bracketed(inner, _) = self {
            allocator.text("(").append(
                allocator
                    .line_()
                    .append(inner.pretty_inner(allocator))
                    .append(allocator.line_())
                    .group()
                    .append(")"),
            )
        } else {
            self.pretty_inner(allocator).nest(INDENT).group()
        }
    }
}

use gibberish_gibberish_parser::GibberishSyntax as S;
use gibberish_gibberish_parser::GibberishToken as T;
use pretty::DocAllocator;
use pretty::DocBuilder;

impl<'a> From<&'a Group<Gibberish>> for ExprAst<'a> {
    fn from(value: &'a Group<Gibberish>) -> Self {
        match value.kind {
            S::Named => ExprAst::Ident(value.token_by_kind(T::Ident).unwrap()),
            S::Seq => ExprAst::Seq(SeqAst(value)),
            S::Choice => ExprAst::Choice(ChoiceAst(value)),
            S::MemberCall => ExprAst::Call(CallAst(value)),
            S::Bracketed => ExprAst::Bracketed(
                Box::new(
                    value
                        .groups()
                        .next()
                        .map(ExprAst::from)
                        .unwrap_or(ExprAst::Empty),
                ),
                value,
            ),
            kind => panic!("Unexpected kind for expr: {kind}"),
        }
    }
}

impl<'a> LspItem<'a> for ExprAst<'a> {
    fn at(&self, offset: usize) -> Option<LspNode<'a>> {
        match self {
            ExprAst::Ident(lexeme) => {
                if lexeme.span.contains(&offset) {
                    Some(LspNode::Expr(self.clone()))
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
            ExprAst::Bracketed(inner, _) => inner.at(offset),
            ExprAst::Empty => None,
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
            ExprAst::Bracketed(expr, _) => expr.check(state),
            ExprAst::Empty => (),
        }
    }

    pub fn check_is(&self, ty: &Type, state: &mut CheckState<'a>) {
        match ty {
            Type::Token => {
                if let ExprAst::Ident(l) = self {
                    if let Some(def) = state.defs.get(&l.text)
                        && matches!(def, StmtAst::Fold(_) | StmtAst::Parser(_))
                    {
                        state.error(
                            "Expected a token but found a parser".to_string(),
                            self.span(),
                        );
                    }
                } else {
                    state.error(
                        "Expected a token but found a parser".to_string(),
                        self.span(),
                    );
                }
            }
            Type::Label => {
                if let ExprAst::Ident(l) = self {
                    if !state.labels.contains(&l.text) {
                        state.labels.push(l.text.clone());
                    }
                } else {
                    state.error(
                        "Expected a label but found a parser".to_string(),
                        self.span(),
                    );
                    self.check(state);
                }
                return;
            }
            _ => (),
        }
        self.check(state);
    }

    pub fn span(&self) -> Span {
        match self {
            ExprAst::Ident(lexeme) => lexeme.span.clone(),
            ExprAst::Seq(s) => s.0.span(),
            ExprAst::Choice(c) => c.0.span(),
            ExprAst::Call(c) => c.0.span(),
            ExprAst::Bracketed(_, expr) => expr.span(),
            ExprAst::Empty => panic!("Empty has no span"),
        }
    }
}
