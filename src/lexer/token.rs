#[derive(logos::Logos, Debug, PartialEq, Eq)]
#[logos(skip r"[ \t\n\f]+")]
pub enum Token {
    #[token("let")]
    Let,
    #[regex(r"[_a-zA-Z]+")]
    Ident,
    #[regex(r"[0-9]+")]
    Int,
    #[token("=")]
    Eq,
}

#[cfg(test)]
mod tests {
    use logos::Logos;

    use super::Token;

    #[test]
    fn basic_test() {
        let input = "let some = 123";
        let mut lex = Token::lexer(input);
        assert_eq!(lex.next(), Some(Ok(Token::Let)));
        assert_eq!(lex.next(), Some(Ok(Token::Ident)));
        assert_eq!(lex.next(), Some(Ok(Token::Eq)));
        assert_eq!(lex.next(), Some(Ok(Token::Int)));
        assert_eq!(lex.next(), None)
    }
}
