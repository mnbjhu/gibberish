use std::{fs, path::Path};

use gibberish_gibberish_parser::Gibberish;

use crate::cli::parse::load_parser;

pub fn lex(path: &Path) {
    let text = fs::read_to_string(path).unwrap();
    let lex = Gibberish::lex(&text);
    for tok in lex {
        println!("{:?}", tok)
    }
}

pub fn lex_custom(path: &Path, parser: &Path) {
    let lang = load_parser(parser);
    let text = fs::read_to_string(path).unwrap();
    let lex = gibberish_dyn_lib::bindings::lex(&lang, &text);
    for tok in lex {
        println!("{tok:?}")
    }
}
