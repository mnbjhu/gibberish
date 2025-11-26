use gibberish_core::node::Group;
use gibberish_gibberish_parser::{Gibberish, GibberishSyntax};

use crate::dsl::ast::stmt::StmtAst;

pub mod expr;
pub mod stmt;

#[derive(Clone, Copy)]
pub struct RootAst<'a>(pub &'a Group<Gibberish>);

impl<'a> RootAst<'a> {
    pub fn iter(&self) -> impl Iterator<Item = StmtAst<'a>> {
        assert_eq!(self.0.kind, GibberishSyntax::Root);
        self.0.green_children().map(StmtAst::from)
    }
}
