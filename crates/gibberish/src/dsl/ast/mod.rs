use crate::{
    dsl::{ast::stmt::StmtAst, lst::lang::DslLang},
    parser::node::Group,
};

pub mod expr;
pub mod stmt;

#[derive(Clone, Copy)]
pub struct RootAst<'a>(pub &'a Group<DslLang>);

impl<'a> RootAst<'a> {
    pub fn iter(&self) -> impl Iterator<Item = StmtAst<'a>> {
        self.0.green_children().map(StmtAst::from)
    }
}
