use std::{collections::HashMap, ops::Range};

use regex_lexer::{Lexer, LexerBuilder};

use super::{lang::PLang, syntax::PSyntax};
use crate::parser::node::Node;

pub struct BuildState<'src> {
    source: &'src str,
    errors: Vec<BuildError>,
    token_ids: HashMap<String, u16>,
    lexer: Option<Lexer<u16>>,
}

pub struct BuildError {
    pub span: Range<usize>,
    pub msg: String,
}

pub fn build_lexer(node: &Node<PLang>, source: &str) -> (Lexer<u16>, Vec<String>) {
    let mut id = 0;
    let mut builder = LexerBuilder::new();
    let mut names = Vec::new();
    for decl in node.green_children() {
        if decl.name() != PSyntax::TokenDecl || !decl.is_okay() {
            continue;
        }

        let name_node = decl.child_by_name(&PSyntax::Var).unwrap();
        let lit_node = decl.child_by_name(&PSyntax::String).unwrap();

        let name = &source[name_node.span()]; // e.g. "NUMBER"
        let raw_pattern = &source[lit_node.span()]; // e.g. "\"[0-9]+\""
        let pattern = raw_pattern.trim_matches('"'); // strip quotes
        names.push(name.to_string());
        // register the regex→token mapping
        builder = builder.token(pattern, id);
        id += id;
    }
    (builder.build().unwrap(), names)
}
