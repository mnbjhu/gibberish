use std::fmt::Display;

#[derive(logos::Logos, Debug, PartialEq, Eq, Clone)]
#[logos(skip r"[ \t\n\f]+")]
pub enum PToken {
    #[regex("\"[^\"]*\"")]
    String,

    #[token("token")]
    Token,

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
}

impl Display for PToken {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            PToken::String => f.write_str("<string>"),
            PToken::Colon => f.write_str(":"),
            PToken::Comma => f.write_str(","),
            PToken::LBracket => f.write_str("["),
            PToken::RBracket => f.write_str("]"),
            PToken::LParen => f.write_str("("),
            PToken::RParen => f.write_str(")"),
            PToken::LBrace => f.write_str("{"),
            PToken::RBrace => f.write_str("}"),
            PToken::Or => f.write_str("|"),
            PToken::Eq => f.write_str("="),
            PToken::Then => f.write_str("->"),
            PToken::SepBy => f.write_str("sep_by"),
            PToken::Delim => f.write_str("delim"),
            PToken::Rec => f.write_str("rec"),
            PToken::Ident => f.write_str("<ident>"),
            PToken::Semi => f.write_str(";"),
            PToken::Fold => f.write_str("fold"),
            PToken::Named => f.write_str("named"),
            PToken::Token => f.write_str("token"),
        }
    }
}
