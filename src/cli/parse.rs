use std::{
    fs::{self, OpenOptions},
    path::Path,
};

use rowan::{Language, NodeOrToken, SyntaxKind, SyntaxNode, cursor::SyntaxElement};

use crate::dsl::{lang::PLang, lexer::PToken, parser::p_parser};

pub fn parse(path: &Path, errors: bool, tokens: bool) {
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

    let text = fs::read_to_string(path).unwrap();
    let (res, errors) = p_parser().parse(&text);
    let node: SyntaxNode<PLang> = SyntaxNode::new_root(res);
    print(0, SyntaxElement::Node(node.into()));
    println!("--------");
    for err in errors {
        println!("{err:?}");
    }
}

pub fn print(indent: usize, element: SyntaxElement) {
    let kind: SyntaxKind = element.kind();
    let pkind: PToken = PLang::kind_from_raw(kind);
    print!("{:indent$}", "", indent = indent);
    match element {
        NodeOrToken::Node(node) => {
            println!("- {pkind:?}");
            for child in node.children_with_tokens() {
                print(indent + 2, child);
            }
        }
        NodeOrToken::Token(token) => println!("- {:?} {:?}", token.text(), pkind),
    }
}
