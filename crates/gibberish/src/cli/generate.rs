use std::fs::remove_dir_all;
use std::{
    env::current_dir,
    fs::{self, create_dir},
    io::{self, Write as _},
    path::{Path, PathBuf},
};

use ansi_term::Color;

use crate::ast::builder::ParserBuilder;
use crate::cli::build::build_parser_from_src;

pub fn generate(src: &Path) {
    let name = src.file_stem().unwrap().to_str().unwrap();
    let mut builder = build_parser_from_src(src);
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
gibberish-core = "0.1.0"
"#
    );
    if !crate_dir.join("Cargo.toml").exists() {
        write_file(&crate_dir.join("Cargo.toml"), &cargo_toml).unwrap();
    }

    use std::fmt::Write;

    let build_rs = format!(
        r#"
// build.rs
//
// Builds a static library from a C source at lib/parser.c and links it into this crate.
// Assumes a C toolchain is available on PATH.
// - Unix: uses `ar` to create lib<basename>.a
// - Windows MSVC: uses `lib.exe` to create <basename>.lib (requires MSVC tools)
// - Windows GNU (MinGW): uses `ar` (still produces .a)

use std::{{
    env,
    path::{{Path, PathBuf}},
    process::Command,
}};

fn main() {{
    // ---- inputs ----
    let c_src = Path::new("lib/parser.c");
    println!("cargo:rerun-if-changed={{}}", c_src.display());

    // Optional: if you have a header and want rebuilds when it changes
    let c_hdr = Path::new("lib/parser.h");
    if c_hdr.exists() {{
        println!("cargo:rerun-if-changed={{}}", c_hdr.display());
    }}

    // ---- environment ----
    let target = env::var("TARGET").expect("TARGET not set");
    let out_dir = PathBuf::from(env::var("OUT_DIR").expect("OUT_DIR not set"));

    // Parameterised static library basename (no "lib" prefix, no extension)
    let lib_basename: &str = "gibberish-parser";

    // ---- derived paths ----
    let obj_path = if target.contains("windows") {{
        out_dir.join("parser.obj")
    }} else {{
        out_dir.join("parser.o")
    }};

    let lib_path = static_lib_filename(&out_dir, &target, lib_basename);

    // ---- 1) CC: C -> object ----
    let cc = env::var("CC").unwrap_or_else(|_| "cc".to_string());

    let mut cc_cmd = Command::new(cc);
    cc_cmd.arg("-c").arg(&c_src).arg("-o").arg(&obj_path);

    // If your C file includes headers from lib/, add include path:
    cc_cmd.arg("-I").arg("lib");

    if !target.contains("windows") {{
        cc_cmd.arg("-fPIC");
    }}

    // Keep your previous debug-ish flags; adjust as desired.
    cc_cmd.arg("-g").arg("-fno-omit-frame-pointer");

    // If you want C standard selection, uncomment:
    // cc_cmd.arg("-std=c11");

    run_cmd(cc_cmd);

    // ---- 2) Archive: object -> static library ----
    if target.contains("windows-msvc") {{
        let lib_tool = env::var("LIB").unwrap_or_else(|_| "lib".to_string());
        let out_flag = format!("/OUT:{{}}", lib_path.to_str().unwrap());
        run(&lib_tool, &[&out_flag, obj_path.to_str().unwrap()]);
    }} else {{
        let ar = env::var("AR").unwrap_or_else(|_| "ar".to_string());
        run(
            &ar,
            &[
                "rcs",
                lib_path.to_str().unwrap(),
                obj_path.to_str().unwrap(),
            ],
        );
    }}

    // ---- 3) Tell Cargo/rustc how to link it ----
    println!("cargo:rustc-link-search=native={{}}", out_dir.display());
    println!("cargo:rustc-link-lib=static={{}}", lib_basename);
}}

fn static_lib_filename(out_dir: &Path, target: &str, basename: &str) -> PathBuf {{
    if target.contains("windows-msvc") {{
        out_dir.join(format!("{{basename}}.lib"))
    }} else {{
        out_dir.join(format!("lib{{basename}}.a"))
    }}
}}

fn run(program: &str, args: &[&str]) {{
    let status = Command::new(program)
        .args(args)
        .status()
        .unwrap_or_else(|e| panic!("failed to run {{program}}: {{e}}"));
    if !status.success() {{
        panic!("{{program}} failed with status {{status}}");
    }}
}}

fn run_cmd(mut cmd: Command) {{
    let status = cmd
        .status()
        .unwrap_or_else(|e| panic!("failed to run command: {{e}}"));
    if !status.success() {{
        panic!("command failed with status {{status}}");
    }}
}}
"#
    );
    write_file(&crate_dir.join("build.rs"), &build_rs).unwrap();

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
    state::{{State, StateData}},
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
