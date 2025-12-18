use gibberish_core::node::{Group, Lexeme};
use gibberish_gibberish_parser::Gibberish;

use crate::ast::{
    CheckError, CheckState, LspItem, LspNode,
    stmt::{fold::FoldDefAst, keyword::KeywordDefAst, parser::ParserDefAst, token::TokenDefAst},
};

pub mod fold;
// pub mod highlight;
pub mod keyword;
pub mod parser;
pub mod token;

#[derive(Clone, Copy)]
pub enum StmtAst<'a> {
    Token(TokenDefAst<'a>),
    Keyword(KeywordDefAst<'a>),
    Parser(ParserDefAst<'a>),
    Fold(FoldDefAst<'a>),
}

impl<'a> StmtAst<'a> {
    pub fn name(&self) -> Option<&'a Lexeme<Gibberish>> {
        match self {
            StmtAst::Token(t) => t.name(),
            StmtAst::Keyword(k) => k.name(),
            StmtAst::Parser(p) => p.name(),
            StmtAst::Fold(f) => f.name(),
        }
    }

    pub fn check(&self, state: &mut CheckState<'a>) {
        if let Some(name) = self.name() {
            if let Some(def) = state.defs.get(&name.text) {
                state.errors.push(CheckError::Redeclaration {
                    previous: def.name().unwrap().span.clone(),
                    this: name.span.clone(),
                    name: name.text.clone(),
                });
            } else {
                state.defs.insert(name.text.clone(), *self);
            }
            state.refs.push(name.clone());
        }
        match self {
            StmtAst::Token(_) => {}
            StmtAst::Keyword(_) => {}
            StmtAst::Parser(p) => p.check(state),
            StmtAst::Fold(f) => f.check(state),
        }
    }
}

impl<'a> LspItem<'a> for StmtAst<'a> {
    fn at(&self, offset: usize) -> Option<LspNode<'a>> {
        match self {
            StmtAst::Token(t) => t.at(offset),
            StmtAst::Keyword(k) => k.at(offset),
            StmtAst::Parser(p) => p.at(offset),
            StmtAst::Fold(f) => f.at(offset),
        }
    }
}

use gibberish_gibberish_parser::GibberishSyntax as S;

impl<'a> From<&'a Group<Gibberish>> for StmtAst<'a> {
    fn from(value: &'a Group<Gibberish>) -> Self {
        match value.kind {
            S::ParserDef => {
                if let Some(expr) = value.groups().next()
                    && expr.kind == S::FoldStmt
                {
                    return StmtAst::Fold(FoldDefAst(value));
                }
                StmtAst::Parser(ParserDefAst(value))
            }
            S::TokenDef => StmtAst::Token(TokenDefAst(value)),
            S::KwDef => StmtAst::Keyword(KeywordDefAst(value)),
            kind => panic!("Unexpected kind for stmt: {kind}"),
        }
    }
}
