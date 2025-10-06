use std::{
    fs::{self},
    path::Path,
};

use tracing_subscriber::{EnvFilter, fmt, layer::SubscriberExt as _, util::SubscriberInitExt as _};

use crate::api::ptr::ParserCache;

use crate::json::parser::json_parser;

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
    let mut cache = ParserCache::new();
    let res = json_parser(&mut cache).parse(&text, &cache);
    res.debug_print(errors, tokens);
}
