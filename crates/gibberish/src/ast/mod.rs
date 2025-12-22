use std::{collections::HashMap, fmt::Display};

use expr::ExprAst;
use gibberish_core::{
    err::ParseError,
    node::{Group, Lexeme, Span},
};
use gibberish_gibberish_parser::Gibberish;
use tower_lsp::lsp_types::{
    CompletionItem, CompletionItemKind, DiagnosticSeverity, HoverContents, MarkedString,
    request::Completion,
};

use crate::{
    ast::{builder::ParserBuilder, stmt::StmtAst},
    lsp::funcs::DEFAULT_FUNCS,
    parser::Parser,
};

pub mod builder;
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
        let mut found_root = false;
        for refr in &state.refs {
            if !state.defs.contains_key(&refr.text) {
                missing.push(refr.span.clone());
            }
        }

        for def in &state.defs {
            if def.0 == "root" {
                found_root = true;
                continue;
            }
            let ref_count = state.refs.iter().filter(|it| &it.text == def.0).count();
            if ref_count <= 1 {
                state
                    .errors
                    .push(CheckError::Unused(def.1.name().unwrap().span.clone()));
            }
        }
        if !found_root {
            state.info("Parser is missing a 'root'".to_string(), 0..=0);
        }
        for span in missing {
            state.error("Parser or token not found".to_string(), span);
        }
    }

    pub fn build_parser(self, builder: &mut ParserBuilder) {
        self.stmts().for_each(|it| match it {
            StmtAst::Parser(p) => {
                builder
                    .vars
                    .push((p.name().unwrap().text.clone(), Parser::Empty));
            }
            StmtAst::Fold(f) => {
                builder
                    .vars
                    .push((f.name().unwrap().text.clone(), Parser::Empty));
            }
            _ => {}
        });
        self.stmts().for_each(|it| match it {
            StmtAst::Parser(p) => p.build(builder),
            StmtAst::Fold(f) => f.build(builder),
            StmtAst::Token(t) => t.build(builder),
            StmtAst::Keyword(k) => k.build(builder),
        });
        for i in 0..builder.vars.len() {
            let res = builder.vars[i].1.clone().remove_conflicts(builder, 0);
            builder.vars[i].1 = res;
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
    ParseError(ParseError<Gibberish>),
}

#[derive(Default)]
pub struct CheckState<'a> {
    pub defs: HashMap<String, StmtAst<'a>>,
    pub refs: Vec<Lexeme<Gibberish>>,
    pub errors: Vec<CheckError>,
    pub func_calls: Vec<Span>,
    pub labels: Vec<String>,
}

impl<'a> CheckState<'a> {
    pub fn error(&mut self, message: String, span: Span) {
        self.errors.push(CheckError::Simple {
            message,
            span,
            severity: DiagnosticSeverity::ERROR,
        });
    }

    pub fn info(&mut self, message: String, span: Span) {
        self.errors.push(CheckError::Simple {
            message,
            span,
            severity: DiagnosticSeverity::INFORMATION,
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

    pub fn completions(&self, _: &CheckState) -> Vec<CompletionItem> {
        dbg!("Getting completions", self.to_string());
        match self {
            LspNode::FunctionName(_) => DEFAULT_FUNCS
                .iter()
                .map(|f| CompletionItem {
                    label: f.name.to_string(),
                    kind: Some(CompletionItemKind::FUNCTION),
                    ..Default::default()
                })
                .collect(),
            _ => vec![],
        }
    }
}

#[allow(dead_code)]
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
