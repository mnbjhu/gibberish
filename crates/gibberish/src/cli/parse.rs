use std::{
    fs::{self},
    path::Path,
};

use gibberish_gibberish_parser::Gibberish;
use gibberish_tree::lang::CompiledLang;

use crate::report::report_errors;

pub fn parse(path: &Path, errors: bool, tokens: bool) {
    let text = fs::read_to_string(path).unwrap();
    let res = Gibberish::parse(&text);
    report_errors(&res, &text, path.to_str().unwrap(), &Gibberish);
    res.debug_print(errors, tokens, &Gibberish);
}

pub fn parse_custom(path: &Path, errors: bool, tokens: bool, parser: &Path) {
    let lang = CompiledLang::load(parser);
    let text = fs::read_to_string(path).unwrap();
    let res = gibberish_dyn_lib::bindings::parse(&lang, &text);
    res.debug_print(errors, tokens, &lang);
}
