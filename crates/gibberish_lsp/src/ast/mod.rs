use std::fmt::Display;

use expr::ExprAst;
use gibberish_core::node::{Group, Lexeme};
use gibberish_gibberish_parser::Gibberish;
use im_rc::HashMap;
use tower_lsp::lsp_types::{DiagnosticSeverity, HoverContents, MarkedString};

use crate::{
    ast::stmt::{
        StmtAst, fold::FoldDefAst, keyword::KeywordDefAst, parser::ParserDefAst, token::TokenDefAst,
    },
    span::Span,
};

pub mod expr;
pub mod stmt;

#[derive(Clone)]
pub struct RootAst<'a>(pub &'a Group<Gibberish>);

impl<'a> RootAst<'a> {
    pub fn stmts(&self) -> impl Iterator<Item = StmtAst<'a>> {
        self.0.groups().map(StmtAst::from)
    }

    pub fn check(&self, state: &mut CheckState<'a>) {
        self.stmts().for_each(|it| it.check(state));
        let mut missing = vec![];
        for refr in &state.refs {
            if !state.defs.contains_key(&refr.text) {
                missing.push(refr.span.clone());
            }
        }

        for def in &state.defs {
            let ref_count = state.refs.iter().filter(|it| &it.text == def.0).count();
            if ref_count <= 1 {
                state
                    .errors
                    .push(CheckError::Unused(def.1.name().unwrap().span.clone()));
            }
        }
        for span in missing {
            state.error("Parser or token not found".to_string(), span);
        }
    }
}

pub enum CheckError {
    Simple {
        message: String,
        span: Span,
        severity: DiagnosticSeverity,
    },
    Unused(Span),
    Redeclaration {
        previous: Span,
        this: Span,
        name: String,
    },
}

pub enum TokenKeywordDefAst<'a> {
    Token(TokenDefAst<'a>),
    Keyword(KeywordDefAst<'a>),
}

pub enum ParserFoldAstDef<'a> {
    Parser(ParserDefAst<'a>),
    Keyword(FoldDefAst<'a>),
}

#[derive(Default)]
pub struct CheckState<'a> {
    pub defs: HashMap<String, StmtAst<'a>>,
    pub refs: Vec<Lexeme<Gibberish>>,
    pub errors: Vec<CheckError>,
    pub func_calls: Vec<Span>,
}

#[derive(Clone)]
pub struct Definition {
    pub definition: Span,
    pub references: Vec<Span>,
}

impl Definition {
    pub fn new(span: Span) -> Self {
        Definition {
            definition: span,
            references: vec![],
        }
    }
}

impl<'a> CheckState<'a> {
    pub fn error(&mut self, message: String, span: Span) {
        self.errors.push(CheckError::Simple {
            message,
            span,
            severity: DiagnosticSeverity::ERROR,
        });
    }

    pub fn warn(&mut self, message: String, span: Span) {
        self.errors.push(CheckError::Simple {
            message,
            span,
            severity: DiagnosticSeverity::WARNING,
        });
    }
}

pub trait LspItem<'a> {
    fn at(&self, offset: usize) -> Option<LspNode<'a>>;
}

impl<'a> LspNode<'a> {
    pub fn hover(&self, _: &CheckState) -> Option<HoverContents> {
        Some(HoverContents::Scalar(MarkedString::String(
            self.to_string(),
        )))
    }

    pub fn definition(&self, state: &CheckState) -> Option<Span> {
        match self {
            LspNode::Expr(ExprAst::Ident(ident)) => state
                .defs
                .get(&ident.text)
                .map(|it| it.name().unwrap().span.clone()),
            _ => None,
        }
    }

    pub fn references(&self, state: &CheckState) -> Vec<Span> {
        match self {
            LspNode::Expr(ExprAst::Ident(ident)) => state
                .refs
                .iter()
                .filter_map(|it| {
                    if it.text == ident.text {
                        Some(&it.span)
                    } else {
                        None
                    }
                })
                .cloned()
                .collect(),
            _ => vec![],
        }
    }
}

pub enum LspNode<'a> {
    Root(RootAst<'a>),
    Expr(ExprAst<'a>),
    Stmt(StmtAst<'a>),
    FunctionName(&'a Lexeme<Gibberish>),
}

impl Display for LspNode<'_> {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            LspNode::Root(_) => write!(f, "Root"),
            LspNode::Expr(_) => write!(f, "Expr"),
            LspNode::Stmt(_) => write!(f, "Stmt"),
            LspNode::FunctionName(_) => write!(f, "FunctionName"),
        }
    }
}

impl<'a> LspItem<'a> for RootAst<'a> {
    fn at(&self, offset: usize) -> Option<LspNode<'a>> {
        for decl in self.stmts() {
            if let Some(res) = decl.at(offset) {
                return Some(res);
            }
        }
        Some(LspNode::Root(self.clone()))
    }
}
