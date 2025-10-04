use std::fmt::Display;

#[derive(logos::Logos, Debug, PartialEq, Eq, Clone, Hash)]
pub enum GToken {
    #[regex(r#"[ \t\n]*;[ \t\n]*"#)]
    Semi,

    #[regex(r#"[ \t]*[\n][ \t\n]*"#)]
    Newline,

    #[regex(r#"[ \t]+"#)]
    Whitespace,

    #[regex(r#""[^"]*""#)]
    String,

    #[regex(r#"\d*\.\d+"#)]
    Float,

    #[regex(r#"\d+"#)]
    Int,

    #[token("::")]
    DoubleColon,

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

    #[token("||")]
    Or,

    #[token("|")]
    Bar,

    #[token("==")]
    DoubleEq,

    #[token("=")]
    Eq,

    #[token("+")]
    Plus,

    #[token("*")]
    Times,

    #[token("/")]
    Div,

    #[token("-")]
    Sub,

    #[token("->")]
    Then,

    #[token("sep")]
    SepBy,

    #[token("named")]
    Named,

    #[token("fn")]
    Fn,

    #[token("struct")]
    Struct,

    #[token("enum")]
    Enum,

    #[token("impl")]
    Impl,

    #[token("trait")]
    Trait,

    #[token("for")]
    For,

    #[token("let")]
    Let,

    #[token("if")]
    If,

    #[token("else")]
    Else,

    #[token("return")]
    Return,

    #[token("true")]
    True,

    #[token("false")]
    False,

    #[token("match")]
    Match,

    #[token("use")]
    Use,

    #[token("while")]
    While,

    #[token("in")]
    In,

    #[token("break")]
    Break,

    #[token("continue")]
    Continue,

    #[regex(r#"[a-zA-Z][a-zA-Z0-9_]*"#, priority = 0)]
    Ident,
    Error,
}

impl Display for GToken {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            GToken::String => f.write_str("String"),
            GToken::Colon => f.write_str("Colon"),
            GToken::Comma => f.write_str("Comma"),
            GToken::LBracket => f.write_str("LBracket"),
            GToken::RBracket => f.write_str("RBracket"),
            GToken::LParen => f.write_str("LParen"),
            GToken::RParen => f.write_str("RParen"),
            GToken::LBrace => f.write_str("LBrace"),
            GToken::RBrace => f.write_str("RBrace"),
            GToken::Bar => f.write_str("Bar"),
            GToken::Eq => f.write_str("Eq"),
            GToken::Then => f.write_str("Then"),
            GToken::SepBy => f.write_str("SepBy"),
            GToken::Ident => f.write_str("Ident"),
            GToken::Semi => f.write_str("Semi"),
            GToken::Named => f.write_str("Named"),
            GToken::Whitespace => f.write_str("Whitespace"),
            GToken::Fn => f.write_str("Fn"),
            GToken::Struct => f.write_str("Struct"),
            GToken::Enum => f.write_str("Enum"),
            GToken::Impl => f.write_str("Impl"),
            GToken::Trait => f.write_str("Trait"),
            GToken::For => f.write_str("For"),
            GToken::Let => f.write_str("Let"),
            GToken::If => f.write_str("If"),
            GToken::Else => f.write_str("Else"),
            GToken::Return => f.write_str("Return"),
            GToken::True => f.write_str("True"),
            GToken::False => f.write_str("False"),
            GToken::Match => f.write_str("Match"),
            GToken::Use => f.write_str("Use"),
            GToken::While => f.write_str("While"),
            GToken::In => f.write_str("In"),
            GToken::Break => f.write_str("Break"),
            GToken::Continue => f.write_str("Continue"),
            GToken::Newline => f.write_str("Newline"),
            GToken::Error => f.write_str("ERR"),
            GToken::Float => f.write_str("Float"),
            GToken::Int => f.write_str("Int"),
            GToken::Or => f.write_str("Or"),
            GToken::Plus => f.write_str("Plus"),
            GToken::Times => f.write_str("Times"),
            GToken::Div => f.write_str("Div"),
            GToken::Sub => f.write_str("Sub"),
            GToken::DoubleEq => f.write_str("DoubleEq"),
            GToken::DoubleColon => f.write_str("DoubleColon"),
        }
    }
}
