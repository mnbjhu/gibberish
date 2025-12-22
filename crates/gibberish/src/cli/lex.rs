use std::{fs, mem, path::Path};

use gibberish_core::{lang::RawLang, node::Lexeme};
use gibberish_dyn_lib::bindings::lang::CompiledLang;
use gibberish_gibberish_parser::Gibberish;

use crate::cli::parse::load_parser;

pub fn lex(path: &Path) {
    let text = fs::read_to_string(path).unwrap();
    let lex = Gibberish::lex(&text);
    for tok in lex {
        tok.debug_at(0, &Gibberish, false);
    }
}

pub fn lex_custom(path: &Path, parser: &Path) {
    let lang = load_parser(parser);
    let text = fs::read_to_string(path).unwrap();
    let lex = gibberish_dyn_lib::bindings::lex(&lang, &text);
    for tok in lex {
        unsafe {
            mem::transmute::<Lexeme<RawLang>, Lexeme<CompiledLang>>(Lexeme::from_data(tok, &text))
                .debug_at(0, &lang, false)
        };
    }
}
