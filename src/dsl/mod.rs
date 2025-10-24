use std::{fs, path::Path};

use crate::{
    api::ptr::{ParserCache, ParserIndex},
    dsl::{
        ast::RootAst,
        lexer::{RuntimeLang, build_lexer},
        lst::{dsl_parser, lang::DslLang, syntax::DslSyntax},
        parser::{ParserBuilder, build_parser},
    },
};

pub mod ast;
pub mod build;
pub mod highlight;
pub mod lexer;
pub mod lst;
pub mod parser;
pub mod regex;

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
    let lexer = build_lexer(dsl_ast, &parser_text, parser_filename);
    let lang = RuntimeLang {
        lexer,
        vars: vec![],
    };
    let mut builder = ParserBuilder::new(lang, &parser_text, parser_filename);
    let parser = build_parser(dsl_ast, &mut builder);
    builder.cache.lang.vars = builder.vars;
    (parser, builder.cache)
}

pub fn build_lex_from_src(parser: &Path) -> (ParserIndex<RuntimeLang>, ParserCache<RuntimeLang>) {
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
    let lexer = build_lexer(dsl_ast, &parser_text, parser_filename);
    let lang = RuntimeLang {
        lexer,
        vars: vec![],
    };
    let mut builder = ParserBuilder::new(lang, &parser_text, parser_filename);
    let parser = build_parser(dsl_ast, &mut builder);
    builder.cache.lang.vars = builder.vars;
    (parser, builder.cache)
}
