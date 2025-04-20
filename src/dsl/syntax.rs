use std::fmt::Display;

#[derive(Debug, PartialEq, Eq, Clone)]
pub enum PSyntax {
    Root,
    String,
    Seq,
    Choice,
    SepBy,
    Fold,
    Rec,
    Named,
    Delim,
    Decl,
    Var,
}

impl Display for PSyntax {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            PSyntax::Root => f.write_str("Root"),
            PSyntax::String => f.write_str("String"),
            PSyntax::Seq => f.write_str("Seq"),
            PSyntax::Choice => f.write_str("Choice"),
            PSyntax::SepBy => f.write_str("SepBy"),
            PSyntax::Fold => f.write_str("Fold"),
            PSyntax::Rec => f.write_str("Rec"),
            PSyntax::Named => f.write_str("Named"),
            PSyntax::Delim => f.write_str("Delim"),
            PSyntax::Decl => f.write_str("Decl"),
            PSyntax::Var => f.write_str("Var"),
        }
    }
}
