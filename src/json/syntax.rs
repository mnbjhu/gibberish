use std::fmt::Display;

#[derive(Debug, PartialEq, Eq, Clone)]
pub enum JsonSyntax {
    String,
    Number,
    Field,
    Array,
    Object,
    Root,
    Key,
    Add,
}

impl Display for JsonSyntax {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            JsonSyntax::String => f.write_str("String"),
            JsonSyntax::Number => f.write_str("Number"),
            JsonSyntax::Field => f.write_str("Field"),
            JsonSyntax::Array => f.write_str("Array"),
            JsonSyntax::Object => f.write_str("Object"),
            JsonSyntax::Root => f.write_str("Root"),
            JsonSyntax::Key => f.write_str("Key"),
            JsonSyntax::Add => f.write_str("Add"),
        }
    }
}
