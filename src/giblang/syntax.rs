use std::fmt::Display;

#[derive(Debug, PartialEq, Eq, Clone)]
pub enum GSyntax {
    Root,
    String,
    Int,
    Float,
    Bool,
    Struct,
    Enum,
    Member,
    Function,
    Field,
    Fields,
    Name,
    TupleFields,
    Type,
    TypeName,
    Decl,
    Var,
    TypeArgs,
    LambdaArg,
    LambdaArgs,
    GenericArg,
    GenericArgs,
    Param,
    Params,
    CodeBlock,
}

impl Display for GSyntax {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            GSyntax::Root => f.write_str("Root"),
            GSyntax::String => f.write_str("String"),
            GSyntax::Int => f.write_str("Int"),
            GSyntax::Float => f.write_str("Float"),
            GSyntax::Bool => f.write_str("Bool"),
            GSyntax::Decl => f.write_str("Decl"),
            GSyntax::Var => f.write_str("Var"),
            GSyntax::Struct => f.write_str("Struct"),
            GSyntax::Enum => f.write_str("Enum"),
            GSyntax::Function => f.write_str("Function"),
            GSyntax::Field => f.write_str("Field"),
            GSyntax::Fields => f.write_str("Fields"),
            GSyntax::Type => f.write_str("Type"),
            GSyntax::TypeName => f.write_str("TypeName"),
            GSyntax::TupleFields => f.write_str("TupleFields"),
            GSyntax::Name => f.write_str("Name"),
            GSyntax::TypeArgs => f.write_str("TypeArgs"),
            GSyntax::Member => f.write_str("Memeber"),
            GSyntax::LambdaArg => f.write_str("LambdaArg"),
            GSyntax::LambdaArgs => f.write_str("LambdaArgs"),
            GSyntax::GenericArg => f.write_str("GenericArg"),
            GSyntax::GenericArgs => f.write_str("GenericArgs"),
            GSyntax::Param => f.write_str("Param"),
            GSyntax::Params => f.write_str("Params"),
            GSyntax::CodeBlock => f.write_str("CodeBlock"),
        }
    }
}
