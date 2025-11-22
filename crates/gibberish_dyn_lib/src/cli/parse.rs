use std::{fs, path::Path};

use gibberish_tree::lang::CompiledLang;
use libloading::Library;

use crate::bindings::parse as p;

pub fn parse(parser: &Path, text: &Path) {
    let lib = unsafe { Library::new(parser).unwrap() };
    let lang = CompiledLang(lib);
    let text = fs::read_to_string(text).unwrap();
    println!("Len: {}", text.len());
    let res = p(&lang, &text);
    res.debug_print(true, true, &lang);
}
