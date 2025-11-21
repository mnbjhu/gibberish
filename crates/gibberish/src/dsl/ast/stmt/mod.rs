use crate::dsl::ast::stmt::highlight::HighlightAst;
use crate::dsl::lst::{lang::DslLang, syntax::DslSyntax as S};
use crate::{
    dsl::ast::stmt::{
        fold::FoldDefAst, keyword::KeywordDefAst, parser::ParserDefAst, token::TokenDefAst,
    },
    parser::node::Group,
};

pub mod fold;
pub mod highlight;
pub mod keyword;
pub mod parser;
pub mod token;

#[derive(Clone, Copy)]
pub enum StmtAst<'a> {
    Token(TokenDefAst<'a>),
    Keyword(KeywordDefAst<'a>),
    Parser(ParserDefAst<'a>),
    Fold(FoldDefAst<'a>),
    Highlight(HighlightAst<'a>),
}

impl<'a> From<&'a Group<DslLang>> for StmtAst<'a> {
    fn from(value: &'a Group<DslLang>) -> Self {
        match value.kind {
            S::ParserDef => {
                if let Some(expr) = value.green_node_by_name(S::Expr)
                    && expr.green_children().next().unwrap().kind == S::Fold
                {
                    return StmtAst::Fold(FoldDefAst(value));
                }
                StmtAst::Parser(ParserDefAst(value))
            }
            S::TokenDef => StmtAst::Token(TokenDefAst(value)),
            S::KeywordDef => StmtAst::Keyword(KeywordDefAst(value)),
            S::Highlight => StmtAst::Highlight(HighlightAst(value)),
            kind => panic!("Unexpected kind for stmt: {kind}"),
        }
    }
}

impl<'a> StmtAst<'a> {
    pub fn name(&self) -> &'a str {
        match self {
            StmtAst::Token(token_def_ast) => &token_def_ast.name().text,
            StmtAst::Keyword(keyword_def_ast) => &keyword_def_ast.name().text,
            StmtAst::Parser(parser_def_ast) => &parser_def_ast.name().text,
            StmtAst::Fold(fold_def_ast) => &fold_def_ast.name().text,
            StmtAst::Highlight(_) => "highlight",
        }
    }
}
