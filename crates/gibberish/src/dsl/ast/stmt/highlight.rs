use crate::{
    dsl::lst::{lang::DslLang, syntax::DslSyntax as S, token::DslToken},
    parser::node::{Group, Lexeme},
};

#[derive(Clone, Copy)]
pub struct HighlightAst<'a>(pub &'a Group<DslLang>);

impl<'a> HighlightAst<'a> {
    pub fn query(&self) -> QueryAst<'a> {
        self.0
            .green_node_by_name(S::Query)
            .or(self.0.green_node_by_name(S::LabelQuery))
            .unwrap()
            .into()
    }
}

#[derive(Clone, Copy)]
pub enum QueryAst<'a> {
    Group(QueryGroupAst<'a>),
    Label(QueryLabelAst<'a>),
}

impl<'a> From<&'a Group<DslLang>> for QueryAst<'a> {
    fn from(value: &'a Group<DslLang>) -> Self {
        match value.kind {
            S::LabelQuery => QueryAst::Label(QueryLabelAst(value)),
            S::Query => QueryAst::Group(QueryGroupAst(value)),
            kind => panic!("Invalid kind: {kind} for QueryAst"),
        }
    }
}

#[derive(Clone, Copy)]
pub struct QueryGroupAst<'a>(pub &'a Group<DslLang>);

impl<'a> QueryGroupAst<'a> {
    pub fn name(&self) -> &'a Lexeme<DslLang> {
        self.0
            .green_node_by_name(S::Name)
            .unwrap()
            .lexeme_by_kind(DslToken::Ident)
            .unwrap()
    }

    pub fn sub_queries(&self) -> impl Iterator<Item = QueryAst> {
        let res: Box<dyn Iterator<Item = QueryAst>> =
            if let Some(children) = self.0.green_node_by_name(S::Group) {
                Box::new(children.green_children().map(QueryAst::from))
            } else {
                Box::new(std::iter::empty())
            };
        res
    }
}

#[derive(Clone, Copy)]
pub struct QueryLabelAst<'a>(pub &'a Group<DslLang>);

impl<'a> QueryLabelAst<'a> {
    pub fn name(&self) -> &'a str {
        self.0
            .green_node_by_name(S::Label)
            .unwrap()
            .lexeme_by_kind(DslToken::String)
            .unwrap()
            .text
            .strip_prefix("\"")
            .unwrap()
            .strip_suffix("\"")
            .unwrap()
    }

    pub fn query(&self) -> QueryAst<'a> {
        self.0
            .green_node_by_name(S::Query)
            .or(self.0.green_node_by_name(S::LabelQuery))
            .unwrap()
            .into()
    }
}
