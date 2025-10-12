use std::fmt::Display;

#[derive(logos::Logos, Debug, PartialEq, Eq, Clone, Hash)]
#[logos(skip r"[ \t\n\f]+")]
pub enum DslToken {
    #[regex("\"(\\\\.|[^\"\\\\])*\"")]
    String,
    #[regex("k\"[^\"]*\"")]
    KwString,
    #[regex(r"[0-9]+")]
    Int,
    #[token(":")]
    Colon,
    #[token(",")]
    Comma,
    #[token("|")]
    Bar,
    #[token(".")]
    Dot,
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
    #[token("+")]
    Plus,
    #[token("*")]
    Mul,

    #[token("highlight")]
    Highlight,
    #[token("token")]
    Token,
    #[token("keyword")]
    Keyword,
    #[token("parser")]
    Parser,
    #[token("fold")]
    Fold,

    #[token("=")]
    Eq,

    #[regex("[_a-zA-Z][_a-zA-Z0-9]*")]
    Ident,

    #[token(";")]
    Semi,

    #[token("@")]
    At,

    Err,
}

impl Display for DslToken {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            DslToken::String => f.write_str("String"),
            DslToken::Int => f.write_str("Int"),
            DslToken::Colon => f.write_str("Colon"),
            DslToken::Comma => f.write_str("Comma"),
            DslToken::LBracket => f.write_str("LBracket"),
            DslToken::RBracket => f.write_str("RBracket"),
            DslToken::LBrace => f.write_str("LBrace"),
            DslToken::RBrace => f.write_str("RBrace"),
            DslToken::Plus => f.write_str("Plus"),
            DslToken::Mul => f.write_str("Mul"),
            DslToken::Ident => f.write_str("Ident"),
            DslToken::Eq => f.write_str("Eq"),
            DslToken::LParen => f.write_str("LParen"),
            DslToken::RParen => f.write_str("RParen"),
            DslToken::Bar => f.write_str("Bar"),
            DslToken::Err => f.write_str("Err"),
            DslToken::Semi => f.write_str("Semi"),
            DslToken::KwString => f.write_str("KwString"),
            DslToken::Dot => f.write_str("Dot"),
            DslToken::Token => f.write_str("Token"),
            DslToken::Keyword => f.write_str("Keyword"),
            DslToken::Parser => f.write_str("Parser"),
            DslToken::Fold => f.write_str("Fold"),
            DslToken::At => f.write_str("At"),
            DslToken::Highlight => f.write_str("Highlight"),
        }
    }
}
