use std::fmt::Display;

#[derive(Debug, PartialEq, Eq, Clone)]
pub enum GSyntax {
    Root,
    String,
    Number,
    Struct,
    Enum,
    Function,
    Fields,
    FieldName,
    TupleFields,
    Type,
    TypeName,
    Decl,
    Var,
    TypeArgs,
}

impl Display for GSyntax {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            GSyntax::Root => f.write_str("Root"),
            GSyntax::String => f.write_str("String"),
            GSyntax::Decl => f.write_str("Decl"),
            GSyntax::Var => f.write_str("Var"),
            GSyntax::Number => f.write_str("Number"),
            GSyntax::Struct => f.write_str("Struct"),
            GSyntax::Enum => f.write_str("Enum"),
            GSyntax::Function => f.write_str("Function"),
            GSyntax::Fields => f.write_str("Fields"),
            GSyntax::Type => f.write_str("Type"),
            GSyntax::TypeName => f.write_str("TypeName"),
            GSyntax::TupleFields => f.write_str("TupleFields"),
            GSyntax::FieldName => f.write_str("FieldName"),
            GSyntax::TypeArgs => f.write_str("TypeArgs"),
        }
    }
}
