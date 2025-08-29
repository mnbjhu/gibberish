use std::{fs, path::Path};

use logos::Logos as _;

use crate::dsl::lexer::GToken;

pub fn lex(path: &Path) {
    let text = fs::read_to_string(path).unwrap();
    let lex = GToken::lexer(&text);
    for tok in lex {
        println!("{:?}", tok.unwrap())
    }
}
