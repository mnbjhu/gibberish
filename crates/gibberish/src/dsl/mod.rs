use std::{fs, path::Path};

use gibberish_gibberish_parser::Gibberish;

use crate::{
    api::ptr::{ParserCache, ParserIndex},
    dsl::{
        ast::RootAst,
        lexer::{RuntimeLang, build_lexer},
        parser::{ParserBuilder, build_parser},
    },
    report::report_errors,
};

pub mod ast;
pub mod build;
pub mod lexer;
pub mod parser;
pub mod regex;

pub fn build_parser_from_src(
    parser: &Path,
) -> (ParserIndex<RuntimeLang>, ParserCache<RuntimeLang>) {
    let parser_text = fs::read_to_string(parser).unwrap();
    let dsl_lst = Gibberish::parse(&parser_text);
    let parser_filename = parser.to_str().unwrap();
    if report_errors(&dsl_lst, &parser_text, parser_filename, &Gibberish) {
        panic!("Failed to build parser")
    }
    let dsl_ast = RootAst(dsl_lst.as_group());
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
    let parser_text = fs::read_to_string(parser).unwrap();
    let dsl_lst = Gibberish::parse(&parser_text);
    let parser_filename = parser.to_str().unwrap();
    if report_errors(&dsl_lst, &parser_text, parser_filename, &Gibberish) {
        panic!("Failed to build parser")
    }
    let dsl_ast = RootAst(dsl_lst.as_group());
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
