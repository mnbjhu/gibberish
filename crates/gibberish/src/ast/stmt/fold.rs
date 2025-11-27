use gibberish_core::node::{Group, Lexeme};
use gibberish_gibberish_parser::Gibberish;

use crate::ast::builder::ParserBuilder;
use crate::ast::expr::ExprAst;
use crate::parser::ptr::ParserIndex;

use gibberish_gibberish_parser::GibberishSyntax as S;
use gibberish_gibberish_parser::GibberishToken as T;

#[derive(Clone, Copy)]
pub struct FoldDefAst<'a>(pub &'a Group<Gibberish>);

impl<'a> FoldDefAst<'a> {
    pub fn name(&self) -> &'a Lexeme<Gibberish> {
        self.0.lexeme_by_kind(T::Ident).unwrap()
    }

    fn fold(&self) -> &'a Group<Gibberish> {
        let res = self.0.green_node_by_name(S::FoldStmt).unwrap();
        assert_eq!(res.kind, S::FoldStmt);
        res
    }

    pub fn first(&self) -> ExprAst<'a> {
        self.fold().green_children().next().unwrap().into()
    }

    pub fn next(&self) -> Option<ExprAst<'a>> {
        let mut iter = self.fold().green_children();
        iter.next().unwrap();
        iter.next().map(|it| it.into())
    }

    pub fn build(&self, builder: &mut ParserBuilder) -> ParserIndex {
        let name = self.name().text.as_str();
        assert!(!name.starts_with("_"), "Fold expressions should be named");
        let name_index = builder.vars.len();
        let first = self.first().build(builder);
        let next = self.next().unwrap().build(builder);
        let p = first.fold_once(name_index as u32, next, &mut builder.cache);
        builder.vars.push((name.to_string(), p.clone()));
        p
    }
}
