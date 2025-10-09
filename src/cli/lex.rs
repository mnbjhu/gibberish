use std::{fs, path::Path};

use crate::{
    api::ptr::ParserCache,
    dsl::{
        ast::RootAst,
        dsl_parser,
        lexer::{RuntimeLang, build_lexer},
        lst::{lang::DslLang, token::DslToken},
    },
    parser::lang::Lang,
};
use logos::Logos as _;

pub fn lex(path: &Path) {
    let text = fs::read_to_string(path).unwrap();
    let lex = DslToken::lexer(&text);
    for tok in lex {
        println!("{:?}", tok.unwrap())
    }
}

pub fn lex_custom(path: &Path, parser: &Path) {
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
    let text = fs::read_to_string(path).unwrap();
    let lex = lang.lex(&text);
    for tok in lex {
        println!(
            "{}: {:?}",
            lexer
                .tokens
                .get(tok.kind as usize)
                .map(|(name, _)| name.as_ref())
                .unwrap_or("ERR"),
            tok.text
        )
    }
}
