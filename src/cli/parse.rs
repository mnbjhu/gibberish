use std::{
    fs::{self},
    path::Path,
};

use crate::dsl::{
    build_parser_from_src,
    lst::{dsl_parser, lang::DslLang},
};

use crate::api::ptr::ParserCache;

pub fn parse(path: &Path, errors: bool, tokens: bool) {
    let text = fs::read_to_string(path).unwrap();
    let mut cache = ParserCache::new(DslLang);
    let res = dsl_parser(&mut cache).parse(&text, &cache);
    res.report_errors(&text, path.to_str().unwrap(), &DslLang);
    res.debug_print(errors, tokens, &DslLang);
}

pub fn parse_custom(path: &Path, errors: bool, tokens: bool, parser: &Path) {
    let (parser, cache) = build_parser_from_src(parser);
    let text = fs::read_to_string(path).unwrap();
    let res = parser.parse(&text, &cache);
    res.debug_print(errors, tokens, &cache.lang);
}
