use std::{
    fs::{self, OpenOptions},
    path::Path,
};

use crate::dsl::{parser::p_parser, validate::build_lexer};

pub fn build(parser_path: &Path, lex_path: &Path) {
    let log = OpenOptions::new()
        .write(true)
        .create(true)
        .truncate(true)
        .open("out.log")
        .unwrap();

    tracing_subscriber::fmt()
        .with_writer(log)
        .with_ansi(false)
        .init();

    let text = fs::read_to_string(parser_path).unwrap();
    let res = p_parser().parse(&text);
    let (lexer, names) = build_lexer(&res, &text);

    let lex_text = fs::read_to_string(lex_path).unwrap();
    for token in lexer.tokens(&lex_text) {
        println!("{}", token.kind)
    }
}
