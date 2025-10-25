use std::{fs, path::Path};

use gibberish::dsl::lst::token::DslToken;

use crate::dsl::ast::RootAst;
use crate::dsl::ast::stmt::highlight::QueryAst;
use crate::dsl::lexer::{RuntimeLang, build_lexer};
use crate::dsl::lst::dsl_parser;
use crate::dsl::lst::syntax::DslSyntax;
use crate::dsl::parser::{ParserBuilder, build_parser};
use crate::{api::ptr::ParserCache, dsl::lst::query::query_parser};

use crate::dsl::{build_parser_from_src, lst::lang::DslLang};

pub fn query(parser_src: &Path, src: &Path, query: &str) {
    let mut d_cache = ParserCache::new(DslLang);
    let d_parser = dsl_parser(&mut d_cache);
    let parser_text = fs::read_to_string(parser_src).unwrap();
    let dsl_lst = d_parser.parse(&parser_text, &d_cache);
    let parser_filename = parser_src.to_str().unwrap();
    if dsl_lst.report_errors(&parser_text, parser_filename, &DslLang) {
        panic!("Failed to build parser")
    }
    let dsl_ast = RootAst(dsl_lst.as_group());
    assert_eq!(dsl_lst.as_group().kind, DslSyntax::Root);
    let lexer = build_lexer(dsl_ast, &parser_text, parser_filename);
    let lang = RuntimeLang {
        lexer,
        vars: vec![],
    };
    let mut builder = ParserBuilder::new(lang, &parser_text, parser_filename);
    let parser = build_parser(dsl_ast, &mut builder);
    builder.cache.lang.vars = builder.vars.clone();

    let text = fs::read_to_string(src).unwrap();
    let ast = parser.parse(&text, &builder.cache);

    let mut cache = ParserCache::new(DslLang);
    let parser = query_parser(&mut cache);
    let query_lst = parser.parse(query, &cache);
    let query = QueryAst::from(query_lst.as_group().green_children().next().unwrap());
    let query = query.build(&builder);
    let mut res = vec![];
    ast.query_all(&query, &mut res);
    for r in &res {
        println!("{r:?}")
    }
}
