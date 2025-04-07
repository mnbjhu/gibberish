use std::{fs, path::Path};

use logos::Logos as _;

use crate::lexer::token::Token;

pub fn lex(path: &Path) {
    let text = fs::read_to_string(path).unwrap();
    let lex = Token::lexer(&text);
    for tok in lex {
        println!("{:?}", tok.unwrap())
    }
}
