use std::{fs, path::Path};

use logos::Logos as _;

use crate::dsl::lexer::PToken;

pub fn lex(path: &Path) {
    let text = fs::read_to_string(path).unwrap();
    let mut lexer = PToken::lexer(&text);
    while let Some(next) = lexer.next() {
        match next {
            Ok(next) => {
                let span = lexer.span();
                println!("{next} {}..{}", span.start, span.end)
            }
            Err(e) => panic!("{e:?}"),
        }
    }
}
