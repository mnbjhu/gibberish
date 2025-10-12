use std::fmt::Display;

#[derive(Debug, PartialEq, Eq, Clone, Copy, Hash)]
pub enum DslSyntax {
    String,
    Number,
    Field,
    Array,
    Optional,
    Root,
    Key,
    Add,
    Name,
    Seq,
    Group,
    Choice,
    Call,
    CallArm,
    Args,
    TokenDef,
    ParserDef,
    KeywordDef,
    Expr,
    Fold,
    Query,
    Label,
    LabelQuery,
    Highlight,
}

impl Display for DslSyntax {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            DslSyntax::String => f.write_str("String"),
            DslSyntax::Number => f.write_str("Number"),
            DslSyntax::Field => f.write_str("Field"),
            DslSyntax::Array => f.write_str("Array"),
            DslSyntax::Optional => f.write_str("Optional"),
            DslSyntax::Root => f.write_str("Root"),
            DslSyntax::Key => f.write_str("Key"),
            DslSyntax::Add => f.write_str("Add"),
            DslSyntax::Name => f.write_str("Name"),
            DslSyntax::Seq => f.write_str("Seq"),
            DslSyntax::Choice => f.write_str("Choice"),
            DslSyntax::Call => f.write_str("Call"),
            DslSyntax::Args => f.write_str("Args"),
            DslSyntax::CallArm => f.write_str("CallArm"),
            DslSyntax::TokenDef => f.write_str("TokenDef"),
            DslSyntax::ParserDef => f.write_str("ParserDef"),
            DslSyntax::KeywordDef => f.write_str("KeywordDef"),
            DslSyntax::Expr => f.write_str("Expr"),
            DslSyntax::Fold => f.write_str("Fold"),
            DslSyntax::Group => f.write_str("Group"),
            DslSyntax::Query => f.write_str("Query"),
            DslSyntax::Label => f.write_str("Label"),
            DslSyntax::LabelQuery => f.write_str("LabelQuery"),
            DslSyntax::Highlight => f.write_str("Highlight"),
        }
    }
}
