use std::fmt::Display;

use rowan::SyntaxKind;

#[repr(u16)]
#[derive(logos::Logos, Debug, PartialEq, Eq, Clone, Copy, PartialOrd, Ord, Hash)]
#[logos(skip r"[ \t\n\f]+")]
pub enum PToken {
    #[regex("\"[^\"]*\"")]
    String = 0,

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
    Sep,

    #[token("named")]
    NamedKw,

    #[token("fold")]
    FoldKw,

    #[token("delim")]
    DelimKw,

    #[token("rec")]
    RecKw,

    #[token(";")]
    Semi,

    #[regex(r#"[a-zA-Z][a-zA-Z0-9_]+"#)]
    Ident,
    Root,
    Seq,
    Choice,
    SepBy,
    Fold,
    Rec,
    Named,
    Delim,
    Decl,
    Var,
    Error,
}

impl From<PToken> for SyntaxKind {
    fn from(kind: PToken) -> Self {
        SyntaxKind(kind as u16)
    }
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
            PToken::Sep => f.write_str("SepBy"),
            PToken::DelimKw => f.write_str("Delim"),
            PToken::RecKw => f.write_str("Rec"),
            PToken::Ident => f.write_str("Ident"),
            PToken::Semi => f.write_str("Semi"),
            PToken::FoldKw => f.write_str("Fold"),
            PToken::NamedKw => f.write_str("Named"),
            PToken::Error => f.write_str("ERR"),
            PToken::Root => f.write_str("Root"),
            PToken::Seq => f.write_str("Seq"),
            PToken::Choice => f.write_str("Choice"),
            PToken::SepBy => f.write_str("SepBy"),
            PToken::Fold => f.write_str("Fold"),
            PToken::Rec => f.write_str("Rec"),
            PToken::Named => f.write_str("Named"),
            PToken::Delim => f.write_str("Delim"),
            PToken::Decl => f.write_str("Decl"),
            PToken::Var => f.write_str("Var"),
        }
    }
}
