use std::fmt::Display;

#[derive(logos::Logos, Debug, PartialEq, Eq, Clone, Hash)]
pub enum PToken {
    #[regex(r"[ \t\n\f]+")]
    Whitespace,
    #[regex("\"[^\"]*\"")]
    String,

    #[token(":")]
    Colon,

    #[token(",")]
    Comma,

    #[token("[")]
    LBracket,

    #[token("]")]
    RBracket,

    #[token("(")]
    LParen,

    #[token(")")]
    RParen,

    #[token("{")]
    LBrace,

    #[token("}")]
    RBrace,

    #[token("|")]
    Or,

    #[token("=")]
    Eq,

    #[token("->")]
    Then,

    #[token("sep")]
    SepBy,

    #[token("named")]
    Named,

    #[token("fold")]
    Fold,

    #[token("delim")]
    Delim,

    #[token("rec")]
    Rec,

    #[token(";")]
    Semi,

    #[regex(r#"[a-zA-Z][a-zA-Z0-9_]+"#)]
    Ident,
    Error,
}

impl Display for PToken {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            PToken::String => f.write_str("String"),
            PToken::Colon => f.write_str("Colon"),
            PToken::Comma => f.write_str("Comma"),
            PToken::LBracket => f.write_str("LBracket"),
            PToken::RBracket => f.write_str("RBracket"),
            PToken::LParen => f.write_str("LParen"),
            PToken::RParen => f.write_str("RParen"),
            PToken::LBrace => f.write_str("LBrace"),
            PToken::RBrace => f.write_str("RBrace"),
            PToken::Or => f.write_str("Or"),
            PToken::Eq => f.write_str("Eq"),
            PToken::Then => f.write_str("Then"),
            PToken::SepBy => f.write_str("SepBy"),
            PToken::Delim => f.write_str("Delim"),
            PToken::Rec => f.write_str("Rec"),
            PToken::Ident => f.write_str("Ident"),
            PToken::Semi => f.write_str("Semi"),
            PToken::Fold => f.write_str("Fold"),
            PToken::Named => f.write_str("Named"),
            PToken::Whitespace => f.write_str("Whitespace"),
            PToken::Error => f.write_str("ERR"),
        }
    }
}
