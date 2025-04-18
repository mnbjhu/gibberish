use std::fmt::Display;

#[derive(logos::Logos, Debug, PartialEq, Eq, Clone)]
#[logos(skip r"[ \t\n\f]+")]
pub enum JsonToken {
    #[regex("\"[^\"]*\"")]
    String,
    #[regex(r"[0-9]+")]
    Int,
    #[token(":")]
    Colon,
    #[token(",")]
    Comma,
    #[token("[")]
    LBracket,
    #[token("]")]
    RBracket,
    #[token("{")]
    LBrace,
    #[token("}")]
    RBrace,
    #[token("+")]
    Plus,
    #[token("*")]
    Mul,
}

impl Display for JsonToken {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            JsonToken::String => f.write_str("String"),
            JsonToken::Int => f.write_str("Int"),
            JsonToken::Colon => f.write_str("Colon"),
            JsonToken::Comma => f.write_str("Comma"),
            JsonToken::LBracket => f.write_str("LBracket"),
            JsonToken::RBracket => f.write_str("RBracket"),
            JsonToken::LBrace => f.write_str("LBrace"),
            JsonToken::RBrace => f.write_str("RBrace"),
            JsonToken::Plus => f.write_str("Plus"),
            JsonToken::Mul => f.write_str("Mul"),
        }
    }
}

#[cfg(test)]
mod tests {
    use logos::Logos;

    use super::JsonToken;

    #[test]
    fn basic_test() {
        let input = "\"test\" : 123 {}";
        let mut lex = JsonToken::lexer(input);
        assert_eq!(lex.next(), Some(Ok(JsonToken::String)));
        assert_eq!(lex.next(), Some(Ok(JsonToken::Colon)));
        assert_eq!(lex.next(), Some(Ok(JsonToken::Int)));
        assert_eq!(lex.next(), Some(Ok(JsonToken::LBrace)));
        assert_eq!(lex.next(), Some(Ok(JsonToken::RBrace)));
        assert_eq!(lex.next(), None)
    }
}
