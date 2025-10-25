use std::{fs, path::Path};

use crate::{
    api::ptr::ParserCache,
    dsl::{
        ast::RootAst,
        lexer::build::build_lexer_qbe,
        lst::{dsl_parser, lang::DslLang},
    },
};

pub fn build(parser: &Path, output: Option<&Path>) {
    let mut d_cache = ParserCache::new(DslLang);
    let d_parser = dsl_parser(&mut d_cache);
    let parser_text = fs::read_to_string(parser).unwrap();
    let dsl_lst = d_parser.parse(&parser_text, &d_cache);
    let dsl_ast = RootAst(dsl_lst.as_group());
    let mut res = String::new();
    build_lexer_qbe(dsl_ast, &parser_text, parser.to_str().unwrap(), &mut res);
    if let Some(out) = output {
        fs::write(out, res).unwrap()
    } else {
        println!("{}", res);
    }
}
