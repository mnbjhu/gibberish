use std::fmt::Write as _;
use std::{
    env::current_dir,
    fs::{self, create_dir},
    io::{self, Write as _},
    path::{Path, PathBuf},
};

use crate::cli::build::build_parser_from_src;
use crate::{
    cli::build::{build_dynamic_lib, build_static_lib},
    dsl::parser::ParserBuilder,
};

pub fn generate(src: &Path) {
    let name = src.file_stem().unwrap().to_str().unwrap();
    let (builder, parser) = build_parser_from_src(src);
    let qbe_str = builder.build_qbe(parser);
    let _ = create_dir("lib");
    build_static_lib(&qbe_str, &PathBuf::from(format!("lib/lib{name}-parser.a")));
    build_dynamic_lib(&qbe_str, &PathBuf::from(format!("lib/{name}-parser.so")));
    build_crate(name, current_dir().unwrap(), &builder);
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
gibberish-core = "0.1.0"
"#
    );
    write_file(&crate_dir.join("Cargo.toml"), &cargo_toml).unwrap();

    let build_rs = format!(
        "
fn main() {{
    println!(\"cargo:rustc-link-search=native=lib\");
    println!(\"cargo:rustc-link-lib=static={name}-parser\");
}}
"
    );
    write_file(&crate_dir.join("build.rs"), &build_rs).unwrap();

    let mut token_body = String::new();
    for (name, _) in &builder.lexer {
        let name = snake_to_upper_camel(name);
        writeln!(&mut token_body, "\t{name},").unwrap();
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
    writeln!(&mut syntax_body, "\tRoot = {},", builder.vars.len()).unwrap();

    let lib_rs = format!(
        "
use std::{{fmt::Display, mem}};

use gibberish_core::{{
    lang::Lang,
    node::{{Lexeme, LexemeData, Node}},
    state::{{State, StateData}},
    vec::{{RawVec, SliceData}},
}};

#[link(name = \"{name}-parser\", kind = \"static\")]
unsafe extern \"C\" {{
    fn lex(ptr: *const u8, len: usize) -> RawVec<LexemeData>;
    fn default_state_ptr(ptr: *const u8, len: usize) -> *const StateData;
    fn parse(ptr: *const StateData) -> u32;
    fn get_state(ptr: *const StateData) -> StateData;
    fn token_name(id: u32) -> SliceData;
    fn group_name(id: u32) -> SliceData;
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
pub enum {struct_name}Token {{
    {token_body}
}}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum {struct_name}Syntax {{
    {syntax_body}
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

impl Lang for {struct_name} {{
    type Token = {struct_name}Token;
    type Syntax = {struct_name}Syntax;

    fn lex(&self, src: &str) -> Vec<Lexeme<Self>> {{
        todo!()
    }}

    fn root(&self) -> Self::Syntax {{
        todo!()
    }}

    // fn token_name(&self, token: &Self::Token) -> String {{
    //     let slice: &str = unsafe {{ token_name(*token) }}.into();
    //     slice.to_string()
    // }}
    //
    // fn syntax_name(&self, syntax: &Self::Syntax) -> String {{
    //     let slice: &str = unsafe {{ group_name(*syntax) }}.into();
    //     slice.to_string()
    // }}
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
            let state_ptr = default_state_ptr(text.as_ptr(), text.len());
            p(state_ptr);
            let state_data = get_state(state_ptr);
            let mut state = State::from_data(state_data, text);
            assert_eq!(state.stack.len(), 1);
            mem::transmute(state.stack.pop().unwrap())
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
