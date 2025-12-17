use rust_lapper::{Interval, Lapper};
use std::fmt::Display;

use crate::{
    ast::RootAst,
    span::Span,
    symbol_table::{ReferenceId, SymbolId, SymbolTable},
};
use thiserror::Error;

pub type Result<T> = std::result::Result<T, SemanticError>;

#[derive(Error, Debug)]
pub enum SemanticError {
    #[error("Undefined variable {name}")]
    UndefinedVariable { name: String, span: Span },
    #[error("Expect element type: {expect_ty}, but got {actual_ty}")]
    ImConsistentArrayType {
        expect_ty: String,
        actual_ty: String,
        span: Span,
    },
}

impl SemanticError {
    pub fn span(&self) -> Span {
        match self {
            SemanticError::UndefinedVariable { span, .. } => span.clone(),
            SemanticError::ImConsistentArrayType { span, .. } => span.clone(),
        }
    }
}

#[derive(Debug)]
pub struct Ctx {
    env: im_rc::Vector<(String, Span)>,
    table: SymbolTable,
}

impl Ctx {
    fn find_symbol(&self, name: &str) -> Option<Span> {
        self.env
            .iter()
            .rev()
            .find_map(|(n, t)| if n == name { Some(t.clone()) } else { None })
    }
}
