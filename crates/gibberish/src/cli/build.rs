use std::cmp::Ordering;
use std::fmt::Write as _;
use std::process::{Command, exit};
use std::{fs, path::Path};

use ansi_term::Color;
use gibberish_gibberish_parser::Gibberish;
use tempfile::{Builder, NamedTempFile};
use tower_lsp::lsp_types::DiagnosticSeverity;

use crate::ast::builder::ParserBuilder;
use crate::cli::parse::{C_EXT, DYN_LIB_EXT, STATIC_LIB_EXT};
use crate::parser::build::build_parser_c;

use crate::ast::{CheckError, CheckState, RootAst};
use crate::lexer::build::create_name_function;

#[derive(Clone, clap::ValueEnum)]
pub enum BuildKind {
    C,
    Static,
    Dynamic,
}

impl BuildKind {
    pub fn from_path(path: &Path) -> Self {
        match path.extension().unwrap().to_str().unwrap() {
            DYN_LIB_EXT => BuildKind::Dynamic,
            STATIC_LIB_EXT => BuildKind::Static,
            C_EXT => BuildKind::C,
            _ => panic!(
                "File format not supported: expected output file ending .{}, .{} or .{}",
                DYN_LIB_EXT, STATIC_LIB_EXT, C_EXT
            ),
        }
    }
}

pub fn build(parser_file: &Path, output: &Path) {
    let res = build_c_str(parser_file);
    match BuildKind::from_path(output) {
        BuildKind::C => fs::write(output, res).unwrap(),
        BuildKind::Static => {
            build_static_lib(&res, output);
        }
        BuildKind::Dynamic => {
            let c = Builder::new().suffix(".c").tempfile().unwrap();
            let c_path = c.path().to_path_buf();
            fs::write(&c, res).unwrap();
            build_dynamic_lib(&c_path, output);
        }
    }
    println!("{}", Color::Green.paint("[Build successful]"));
}

pub fn build_c_str(parser_file: &Path) -> String {
    let mut builder = build_parser_from_src(parser_file);
    builder.build_c()
}

impl ParserBuilder {
    pub fn build_c(&mut self) -> String {
        let mut group_names = self.vars.iter().map(|it| it.0.as_str()).collect::<Vec<_>>();
        group_names.push("unmatched");
        if !self.vars.iter().any(|(it, _)| it == "root") {
            group_names.push("root");
        }
        let mut res = String::new();
        let pre = include_str!("../../pre.c");
        write!(&mut res, "{}", pre).unwrap();
        create_name_function(&mut res, "group", &group_names);
        create_name_function(&mut res, "label", &self.labels);
        create_name_function(
            &mut res,
            "token",
            &self.lexer.iter().map(|(name, _)| name).collect::<Vec<_>>(),
        );
        build_parser_c(self, &mut res);
        res
    }
}

pub fn build_parser_from_src(parser_file: &Path) -> ParserBuilder {
    let parser_text = fs::read_to_string(parser_file).unwrap();
    let res = Gibberish::parse(&parser_text);
    let parser_filename = parser_file.to_str().unwrap();
    let dsl_ast = RootAst(res.as_group());
    let mut state = CheckState::default();
    res.all_errors()
        .for_each(|(_, it)| state.errors.push(CheckError::ParseError(it.clone())));
    dsl_ast.check(&mut state);
    state.errors.sort_by(|first, second| match (first, second) {
        (
            CheckError::Simple { span, .. },
            CheckError::Simple {
                span: other_span, ..
            },
        ) => span.start.cmp(&other_span.start),
        (CheckError::Unused(span), CheckError::Unused(other_span)) => {
            span.start.cmp(&other_span.start)
        }
        (
            CheckError::Redeclaration { this: span, .. },
            CheckError::Redeclaration {
                this: other_span, ..
            },
        ) => span.start.cmp(&other_span.start),
        (CheckError::ParseError(_), _) => Ordering::Greater,
        (_, CheckError::ParseError(_)) => Ordering::Less,
        (CheckError::Simple { .. }, _) => Ordering::Greater,
        (_, CheckError::Simple { .. }) => Ordering::Less,
        (CheckError::Redeclaration { .. }, _) => Ordering::Greater,
        (_, CheckError::Redeclaration { .. }) => Ordering::Less,
    });
    for err in &state.errors {
        err.report(&parser_text, parser_filename);
    }
    let has_err = state.errors.iter().any(|it| match it {
        CheckError::Simple { severity, .. } => *severity == DiagnosticSeverity::ERROR,
        CheckError::Unused(_) => false,
        CheckError::Redeclaration { .. } => true,
        CheckError::ParseError(_) => true,
    });
    if has_err {
        println!(
            "{} failed to build parser due to previous errors",
            Color::Red.paint("[Build failed]")
        );
        exit(1)
    } else {
        let mut builder =
            ParserBuilder::new(parser_text, parser_filename.to_string(), state.labels);
        dsl_ast.build_parser(&mut builder);
        builder
    }
}

pub fn build_static_lib(c_text: &str, out: &Path) {
    let c_file = Builder::new().suffix(".c").tempfile().unwrap();
    let c_path = c_file.path().to_path_buf();

    let obj_file = Builder::new().suffix(".o").tempfile().unwrap();
    let obj_path = obj_file.path().to_path_buf();

    fs::write(&c_path, c_text).unwrap();

    // C -> object
    let status = Command::new("cc")
        .arg("-g")
        .arg("-fno-omit-frame-pointer")
        .arg("-c")
        // .arg("-fPIC") // enable if you want PIC objects in your .a
        .arg(&c_path)
        .arg("-o")
        .arg(&obj_path)
        .status()
        .unwrap();
    assert!(status.success(), "cc failed");

    // object -> static archive
    let status = Command::new("ar")
        .arg("rcs")
        .arg(out)
        .arg(&obj_path)
        .status()
        .unwrap();
    assert!(status.success(), "ar failed");
}

/// Build a shared library from a C source file.
///
/// - Compiles `.c` to PIC `.o`
/// - Links into a shared lib at `out` (typically `.so` / `.dylib`)
pub fn build_dynamic_lib(c_path: &Path, out: &Path) {
    let obj_file = Builder::new().suffix(".o").tempfile().unwrap();
    let obj_path = obj_file.path().to_path_buf();

    // C -> PIC object
    let status = Command::new("cc")
        .arg("-c")
        .arg("-fPIC")
        .arg(c_path)
        .arg("-o")
        .arg(&obj_path)
        .status()
        .unwrap();
    assert!(status.success(), "cc -c failed");

    // object -> shared lib
    let status = Command::new("cc")
        .arg("-shared")
        .arg("-o")
        .arg(out)
        .arg(&obj_path)
        .status()
        .unwrap();
    assert!(status.success(), "cc -shared failed");
}
