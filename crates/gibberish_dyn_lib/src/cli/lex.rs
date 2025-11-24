use std::{fs, path::Path};

use gibberish_tree::lang::CompiledLang;

use crate::bindings::lex as l;

pub fn lex(parser: &Path, text: &Path) {
    let lang = CompiledLang::load(parser);
    let text = fs::read_to_string(text).unwrap();
    let res = l(&lang, &text);
    println!("Len: {}", text.len());
    for t in res {
        println!("{t:?}",)
    }
}
