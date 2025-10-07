use std::{
    collections::HashMap,
    fs::{self},
    path::Path,
};

use crate::{dsl::parser::build_parser, parser::lang::Lang as _};
use tracing_subscriber::{EnvFilter, fmt, layer::SubscriberExt as _, util::SubscriberInitExt as _};

use crate::{
    api::ptr::ParserCache,
    dsl::{
        ast::RootAst,
        lang::{DslLang, dsl_parser},
        lexer::{RuntimeLang, build_lexer},
        parser::ParserBuilder,
    },
};

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
    res.debug_print(errors, tokens, &DslLang);
}

pub fn parse_custom(path: &Path, errors: bool, tokens: bool, parser: &Path) {
    let mut d_cache = ParserCache::new(DslLang);
    let d_parser = dsl_parser(&mut d_cache);
    let parser_text = fs::read_to_string(parser).unwrap();
    let dsl_lst = d_parser.parse(&parser_text, &d_cache);
    let dsl_ast = RootAst(dsl_lst.as_group());
    let lexer = build_lexer(dsl_ast);
    let lang = RuntimeLang {
        lexer: &lexer,
        vars: &[],
    };
    let mut builder = ParserBuilder::new(lang, &lexer);
    let parser = build_parser(dsl_ast, &mut builder);
    let lang = RuntimeLang {
        lexer: &lexer,
        vars: &builder.vars,
    };
    let text = fs::read_to_string(path).unwrap();
    let res = parser.parse(&text, &builder.cache);
    res.debug_print(errors, tokens, &lang);
}
