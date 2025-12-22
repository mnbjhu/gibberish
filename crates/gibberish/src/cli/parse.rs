use std::{
    fs::{self},
    path::Path,
};

use gibberish_dyn_lib::bindings::lang::CompiledLang;
use gibberish_gibberish_parser::Gibberish;
use tempfile::Builder;

use crate::{
    cli::build::{build_c_str, build_dynamic_lib},
    report::report_errors,
};

pub const C_EXT: &str = "c";
pub const GIBBERISH_EXT: &str = "gib";

// --- Dynamic library extension (per-platform) ---
#[cfg(target_os = "linux")]
pub const DYN_LIB_EXT: &str = "so";

#[cfg(target_os = "macos")]
pub const DYN_LIB_EXT: &str = "dylib";

#[cfg(windows)]
pub const DYN_LIB_EXT: &str = "dll";

// --- Static library extension (per-platform) ---
#[cfg(any(target_os = "linux", target_os = "macos"))]
pub const STATIC_LIB_EXT: &str = "a";

#[cfg(windows)]
pub const STATIC_LIB_EXT: &str = "lib";

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
        C_EXT => {
            build_dynamic_lib(parser, &lib_path);
            lib_path
        }
        GIBBERISH_EXT => {
            let c_str = build_c_str(parser);
            let c = Builder::new().suffix(".c").tempfile().unwrap();
            fs::write(&c, c_str).unwrap();
            let lib_path = lib.path().to_path_buf();
            build_dynamic_lib(c.path(), &lib_path);
            lib_path
        }
        _ => {
            panic!(
                "File format not supported: expected parser file ending .{}, .{} or .{}",
                DYN_LIB_EXT, GIBBERISH_EXT, C_EXT
            )
        }
    };
    CompiledLang::load(&parser)
}
