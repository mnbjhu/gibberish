use std::{fs, path::Path};

use crate::dsl::build::build_parser_qbe;

use crate::dsl::lexer::build::create_name_function;
use crate::{
    api::ptr::ParserCache,
    dsl::{
        ast::RootAst,
        lexer::{RuntimeLang, build::build_lexer_qbe, build_lexer},
        lst::{dsl_parser, lang::DslLang, syntax::DslSyntax},
        parser::{ParserBuilder, build_parser},
    },
};

pub fn build(parser_file: &Path, output: Option<&Path>) {
    let mut d_cache = ParserCache::new(DslLang);
    let d_parser = dsl_parser(&mut d_cache);
    let parser_text = fs::read_to_string(parser_file).unwrap();
    let dsl_lst = d_parser.parse(&parser_text, &d_cache);
    let dsl_ast = RootAst(dsl_lst.as_group());
    assert_eq!(dsl_lst.as_group().kind, DslSyntax::Root);
    let parser_filename = parser_file.to_str().unwrap();
    let lexer = build_lexer(dsl_ast, &parser_text, parser_filename);
    let lang = RuntimeLang {
        lexer,
        vars: vec![],
    };

    let mut builder = ParserBuilder::new(lang, &parser_text, parser_filename);
    let parser = build_parser(dsl_ast, &mut builder);
    builder.cache.lang.vars = builder.vars;
    let mut group_names = builder
        .cache
        .lang
        .vars
        .iter()
        .map(|it| it.0.as_str())
        .collect::<Vec<_>>();
    group_names.push("root");
    let mut res = String::new();
    build_lexer_qbe(dsl_ast, &parser_text, parser_filename, &mut res);
    build_parser_qbe(&parser, &builder.cache, &mut res);
    create_name_function(&mut res, "group", &group_names);
    if let Some(out) = output {
        fs::write(out, res).unwrap()
    } else {
        println!("{}", res);
    }
}
