use std::{fs, path::Path};

use gibberish_core::lang::CompiledLang;

use crate::bindings::parse as p;

pub fn parse(parser: &Path, text: &Path) {
    let lang = CompiledLang::load(parser);
    let text = fs::read_to_string(text).unwrap();
    let res = p(&lang, &text);
    res.debug_print(true, true, &lang);
}
