use std::{fs, path::Path};

use gibberish_tree::{
    lang::{CompiledLang, Lang},
    node::Lexeme,
};

use crate::bindings::lex as l;

pub fn lex(parser: &Path, text: &Path) {
    let lang = CompiledLang::load(parser);
    let text = fs::read_to_string(text).unwrap();
    let res = l(&lang, &text);
    for t in res {
        let t = Lexeme::from_data(t, &text);
        let name = lang.token_name(&t.kind);
        println!("{}: {:?}@{}..{}", name, t.text, t.span.start, t.span.end)
    }
}
