use gibberish_core::node::Group;
use gibberish_gibberish_parser::Gibberish;

use crate::ast::stmt::{
    fold::FoldDefAst, keyword::KeywordDefAst, parser::ParserDefAst, token::TokenDefAst,
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
    // #[allow(unused)]
    // Highlight(HighlightAst<'a>),
}

use gibberish_gibberish_parser::GibberishSyntax as S;

impl<'a> From<&'a Group<Gibberish>> for StmtAst<'a> {
    fn from(value: &'a Group<Gibberish>) -> Self {
        match value.kind {
            S::ParserDef => {
                if let Some(expr) = value.green_children().next()
                    && expr.kind == S::FoldStmt
                {
                    return StmtAst::Fold(FoldDefAst(value));
                }
                StmtAst::Parser(ParserDefAst(value))
            }
            S::TokenDef => StmtAst::Token(TokenDefAst(value)),
            S::KwDef => StmtAst::Keyword(KeywordDefAst(value)),
            // S::HighlightDef => StmtAst::Highlight(HighlightAst(value)),
            kind => panic!("Unexpected kind for stmt: {kind}"),
        }
    }
}
