use std::{
    fs::{self},
    path::Path,
};

use crate::api::ptr::ParserIndex;
use crate::dsl::lst::syntax::DslSyntax;
use crate::dsl::{
    lst::{dsl_parser, lang::DslLang},
    parser::build_parser,
};
use tracing_subscriber::{EnvFilter, fmt, layer::SubscriberExt as _, util::SubscriberInitExt as _};

use crate::{
    api::ptr::ParserCache,
    dsl::{
        ast::RootAst,
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
    res.report_errors(&text, path.to_str().unwrap(), &DslLang);
    res.debug_print(errors, tokens, &DslLang);
}

pub fn build_parser_from_src(
    parser: &Path,
) -> (ParserIndex<RuntimeLang>, ParserCache<RuntimeLang>) {
    let mut d_cache = ParserCache::new(DslLang);
    let d_parser = dsl_parser(&mut d_cache);
    let parser_text = fs::read_to_string(parser).unwrap();
    let dsl_lst = d_parser.parse(&parser_text, &d_cache);
    let parser_filename = parser.to_str().unwrap();
    if dsl_lst.report_errors(&parser_text, parser_filename, &DslLang) {
        panic!("Failed to build parser")
    }
    let dsl_ast = RootAst(dsl_lst.as_group());
    assert_eq!(dsl_lst.as_group().kind, DslSyntax::Root);
    let lexer = build_lexer(dsl_ast);
    let lang = RuntimeLang {
        lexer,
        vars: vec![],
    };
    let mut builder = ParserBuilder::new(lang, &parser_text, parser_filename);
    let parser = build_parser(dsl_ast, &mut builder);
    builder.cache.lang.vars = builder.vars;
    (parser, builder.cache)
}

pub fn parse_custom(path: &Path, errors: bool, tokens: bool, parser: &Path) {
    let (parser, mut cache) = build_parser_from_src(path);
    let text = fs::read_to_string(path).unwrap();
    let res = parser.parse(&text, &mut cache);
    res.debug_print(errors, tokens, &cache.lang);
}
