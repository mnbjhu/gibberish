use std::{
    fs::{self},
    path::Path,
};

use gibberish_core::lang::CompiledLang;
use gibberish_gibberish_parser::Gibberish;
use tempfile::{Builder, NamedTempFile};

use crate::{
    cli::build::{build_dynamic_lib, build_qbe_str},
    report::report_errors,
};

pub const QBE_EXT: &str = "qbe";
pub const GIBBERISH_EXT: &str = "gib";
pub const DYN_LIB_EXT: &str = "so";
pub const STATIC_LIB_EXT: &str = "a";

pub fn parse(path: &Path, errors: bool, tokens: bool) {
    let text = fs::read_to_string(path).unwrap();
    let res = Gibberish::parse(&text);
    report_errors(&res, &text, path.to_str().unwrap(), &Gibberish);
    res.debug_print(errors, tokens, &Gibberish);
}

pub fn parse_custom(path: &Path, errors: bool, tokens: bool, parser: &Path) {
    let lang = load_parser(parser);
    let text = fs::read_to_string(path).unwrap();
    let res = gibberish_dyn_lib::bindings::parse(&lang, &text);
    res.debug_print(errors, tokens, &lang);
}

pub fn load_parser(parser: &Path) -> CompiledLang {
    let lib = Builder::new()
        .suffix(&format!(".{DYN_LIB_EXT}"))
        .tempfile()
        .unwrap();
    let lib_path = lib.path().to_path_buf();
    let parser = match parser.extension().unwrap().to_str().unwrap() {
        DYN_LIB_EXT => parser.canonicalize().unwrap(),
        QBE_EXT => {
            build_dynamic_lib(parser, &lib_path);
            lib_path
        }
        GIBBERISH_EXT => {
            let qbe_str = build_qbe_str(parser);
            let qbe = NamedTempFile::new().unwrap();
            fs::write(&qbe, qbe_str).unwrap();
            let lib_path = lib.path().to_path_buf();
            build_dynamic_lib(qbe.path(), &lib_path);
            lib_path
        }
        _ => {
            panic!(
                "File format not supported: expected parser file ending .{}, .{} or .{}",
                DYN_LIB_EXT, GIBBERISH_EXT, QBE_EXT
            )
        }
    };
    CompiledLang::load(&parser)
}
