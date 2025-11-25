use gibberish_gibberish_parser::{Gibberish, GibberishToken};
use gibberish_tree::node::{Group, Lexeme};

#[derive(Clone, Copy)]
pub struct HighlightAst<'a>(pub &'a Group<Gibberish>);

use gibberish_gibberish_parser::GibberishSyntax as S;

impl<'a> HighlightAst<'a> {
    pub fn query(&self) -> QueryAst<'a> {
        self.0
            .green_node_by_name(S::GroupQuery)
            .or(self.0.green_node_by_name(S::LabelledQuery))
            .unwrap()
            .into()
    }
}

#[derive(Clone, Copy)]
pub enum QueryAst<'a> {
    Group(QueryGroupAst<'a>),
    Label(QueryLabelAst<'a>),
}

impl<'a> From<&'a Group<Gibberish>> for QueryAst<'a> {
    fn from(value: &'a Group<Gibberish>) -> Self {
        match value.kind {
            S::LabelledQuery => QueryAst::Label(QueryLabelAst(value)),
            S::GroupQuery => QueryAst::Group(QueryGroupAst(value)),
            kind => panic!("Invalid kind: {kind} for QueryAst"),
        }
    }
}

#[derive(Clone, Copy)]
pub struct QueryGroupAst<'a>(pub &'a Group<Gibberish>);

impl<'a> QueryGroupAst<'a> {
    pub fn name(&self) -> &'a Lexeme<Gibberish> {
        self.0
            .green_node_by_name(S::Named)
            .unwrap()
            .lexeme_by_kind(GibberishToken::Ident)
            .unwrap()
    }

    pub fn sub_queries(&self) -> impl Iterator<Item = QueryAst> {
        let res: Box<dyn Iterator<Item = QueryAst>> =
            if let Some(children) = self.0.green_node_by_name(S::ChildQuery) {
                Box::new(children.green_children().map(QueryAst::from))
            } else {
                Box::new(std::iter::empty())
            };
        res
    }
}

#[derive(Clone, Copy)]
pub struct QueryLabelAst<'a>(pub &'a Group<Gibberish>);

impl<'a> QueryLabelAst<'a> {
    pub fn name(&self) -> &'a str {
        self.0
            .green_node_by_name(S::Label)
            .unwrap()
            .lexeme_by_kind(GibberishToken::String)
            .unwrap()
            .text
            .strip_prefix("\"")
            .unwrap()
            .strip_suffix("\"")
            .unwrap()
    }

    pub fn query(&self) -> QueryAst<'a> {
        self.0
            .green_node_by_name(S::GroupQuery)
            .or(self.0.green_node_by_name(S::LabelledQuery))
            .unwrap()
            .into()
    }
}
