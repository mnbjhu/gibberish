use std::fs::remove_dir_all;
use std::{
    env::current_dir,
    fs::{self, create_dir},
    io::{self, Write as _},
    path::{Path, PathBuf},
};

use ansi_term::Color;
use tower_lsp::lsp_types::DiagnosticSeverity;

use crate::ast::builder::ParserBuilder;
use crate::cli::build::build_parser_from_src;

pub fn generate(src: &Path) {
    let name = src.file_stem().unwrap().to_str().unwrap();
    let mut builder = build_parser_from_src(src, DiagnosticSeverity::WARNING);
    let qbe_str = builder.build_c();
    let _ = remove_dir_all("lib");
    let _ = create_dir("lib");
    let crate_dir = current_dir().unwrap();
    write_file(&crate_dir.join("lib/parser.c"), &qbe_str).unwrap();
    build_crate(name, crate_dir, &builder);
    println!("{}", Color::Green.paint("[Build successful]"));
}

fn kebab_to_upper_camel(input: &str) -> String {
    input
        .split('-')
        .filter(|s| !s.is_empty())
        .map(|word| {
            let mut chars = word.chars();
            match chars.next() {
                None => String::new(),
                Some(first) => first.to_uppercase().collect::<String>() + chars.as_str(),
            }
        })
        .collect::<String>()
}

fn snake_to_upper_camel(input: &str) -> String {
    input
        .split('_')
        .filter(|s| !s.is_empty())
        .map(|word| {
            let mut chars = word.chars();
            match chars.next() {
                None => String::new(),
                Some(first) => first.to_uppercase().collect::<String>() + chars.as_str(),
            }
        })
        .collect::<String>()
}

fn build_crate(name: &str, crate_dir: PathBuf, builder: &ParserBuilder) {
    let struct_name = kebab_to_upper_camel(name);
    let cargo_toml = format!(
        r#"[package]
name = "{name}-gibberish-parser"
version = "0.1.0"
edition = "2021"

# Adjust as needed for your workspace/publishing
[lib]
path = "src/lib.rs"

[dependencies]
gibberish-core = "0.3.0"

[build-dependencies]
cc = "1.2"
"#
    );
    if !crate_dir.join("Cargo.toml").exists() {
        write_file(&crate_dir.join("Cargo.toml"), &cargo_toml).unwrap();
    }

    use std::fmt::Write;

    let build_rs = r#"
fn main() {{
    println!("cargo:rerun-if-changed=lib/parser.c");

    cc::Build::new()
        .file("lib/parser.c")
        .compile("gibberish-parser");
}}
"#;
    write_file(&crate_dir.join("build.rs"), build_rs).unwrap();

    let mut token_body = String::new();
    for (name, _) in &builder.lexer {
        let name = snake_to_upper_camel(name);
        writeln!(&mut token_body, "\t{name},").unwrap();
    }
    writeln!(&mut token_body, "\tErr,").unwrap();

    let mut label_body = String::new();
    for name in &builder.labels {
        let name = snake_to_upper_camel(name);
        writeln!(&mut label_body, "\t{name},").unwrap();
    }
    if builder.labels.is_empty() {
        writeln!(&mut label_body, "\tNone,").unwrap();
    }

    let mut syntax_body = String::new();
    for (index, name) in builder
        .vars
        .iter()
        .enumerate()
        .filter_map(|(index, (name, _))| {
            if name.starts_with('_') {
                None
            } else {
                Some((index, name))
            }
        })
    {
        let name = snake_to_upper_camel(name);
        writeln!(&mut syntax_body, "\t{name} = {},", index).unwrap();
    }
    writeln!(&mut syntax_body, "\tUnmatched = {},", builder.vars.len()).unwrap();

    let lib_rs = format!(
        "
use std::{{fmt::Display, mem}};

use gibberish_core::{{
    lang::Lang,
    node::{{Lexeme, LexemeData, Node, NodeData}},
    vec::RawVec,
}};


unsafe extern \"C\" {{
    fn lex(ptr: *const u8, len: usize) -> RawVec<LexemeData>;
    fn parse(ptr: *const u8, len: usize) -> NodeData;
}}

use parse as p;

impl Display for {struct_name} {{
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {{
        write!(f, \"{struct_name}\")
    }}
}}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub struct {struct_name};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u32)]
pub enum {struct_name}Token {{
    {token_body}
}}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u32)]
pub enum {struct_name}Syntax {{
    {syntax_body}
}}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u32)]
pub enum {struct_name}Label {{
    {label_body}
}}

impl Display for {struct_name}Token {{
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {{
        write!(f, \"{{:?}}\", self)
    }}
}}

impl Display for {struct_name}Syntax {{
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {{
        write!(f, \"{{:?}}\", self)
    }}
}}

impl Display for {struct_name}Label {{
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {{
        write!(f, \"{{:?}}\", self)
    }}
}}

impl Lang for {struct_name} {{
    type Token = {struct_name}Token;
    type Syntax = {struct_name}Syntax;
    type Label = {struct_name}Label;
}}

impl {struct_name} {{
    pub fn lex(text: &str) -> Vec<Lexeme<{struct_name}>> {{
        unsafe {{
            Vec::from(lex(text.as_ptr(), text.len()))
                .into_iter()
                .map(|it| {{
                    let temp = Lexeme::from_data(it, text);
                    mem::transmute(temp)
                }})
                .collect()
        }}
    }}

    pub fn parse(text: &str) -> Node<{struct_name}> {{
        unsafe {{
            let n = p(text.as_ptr(), text.len());
            mem::transmute(Node::from_data(n, text, &mut 0))
        }}
    }}
}}
"
    );
    write_file(&crate_dir.join("src/lib.rs"), &lib_rs).unwrap();
}

fn write_file(path: &Path, contents: &str) -> io::Result<()> {
    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent)?;
    }
    let mut f = fs::File::create(path)?;
    f.write_all(contents.as_bytes())
}
