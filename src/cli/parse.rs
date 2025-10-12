use std::{
    fs::{self},
    path::Path,
};

use crate::dsl::{
    build_parser_from_src,
    lst::{dsl_parser, lang::DslLang},
};
use tracing_subscriber::{EnvFilter, fmt, layer::SubscriberExt as _, util::SubscriberInitExt as _};

use crate::api::ptr::ParserCache;

pub fn parse(path: &Path, errors: bool, tokens: bool) {
    let fmt_layer = fmt::layer().with_target(false);
    let filter_layer = EnvFilter::try_from_default_env()
        .or_else(|_| EnvFilter::try_new("info"))
        .unwrap();

    tracing_subscriber::registry()
        .with(filter_layer)
        .with(fmt_layer)
        .init();

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
