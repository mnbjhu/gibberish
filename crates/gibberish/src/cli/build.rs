use std::cmp::Ordering;
use std::fmt::Write as _;
use std::process::Command;
use std::{fs, path::Path};

use gibberish_gibberish_parser::Gibberish;
use tempfile::{Builder, NamedTempFile};
use tower_lsp::lsp_types::DiagnosticSeverity;

use crate::ast::builder::ParserBuilder;
use crate::cli::parse::{DYN_LIB_EXT, QBE_EXT, STATIC_LIB_EXT};
use crate::parser::build::build_parser_qbe;

use crate::ast::{CheckError, CheckState, RootAst};
use crate::lexer::build::create_name_function;
use crate::report::report_errors;

#[derive(Clone, clap::ValueEnum)]
pub enum BuildKind {
    Qbe,
    Static,
    Dynamic,
}

impl BuildKind {
    pub fn from_path(path: &Path) -> Self {
        match path.extension().unwrap().to_str().unwrap() {
            DYN_LIB_EXT => BuildKind::Dynamic,
            STATIC_LIB_EXT => BuildKind::Static,
            QBE_EXT => BuildKind::Qbe,
            _ => panic!(
                "File format not supported: expected output file ending .{}, .{} or .{}",
                DYN_LIB_EXT, STATIC_LIB_EXT, QBE_EXT
            ),
        }
    }
}

pub fn build(parser_file: &Path, output: Option<&Path>) {
    let res = build_qbe_str(parser_file);
    if let Some(out) = output {
        match BuildKind::from_path(out) {
            BuildKind::Qbe => fs::write(out, res).unwrap(),
            BuildKind::Static => {
                build_static_lib(&res, out);
            }
            BuildKind::Dynamic => {
                let qbe = NamedTempFile::new().unwrap();
                let qbe_path = qbe.path().to_path_buf();
                fs::write(&qbe, res).unwrap();
                build_dynamic_lib(&qbe_path, out);
            }
        }
    } else {
        println!("{}", res);
    }
}

pub fn build_qbe_str(parser_file: &Path) -> String {
    let mut builder = build_parser_from_src(parser_file);
    builder.build_qbe()
}

impl ParserBuilder {
    pub fn build_qbe(&mut self) -> String {
        let mut group_names = self.vars.iter().map(|it| it.0.as_str()).collect::<Vec<_>>();
        group_names.push("root");
        group_names.push("unmatched");
        let mut res = String::new();
        let pre = include_str!("../../pre.qbe");
        write!(&mut res, "{}", pre).unwrap();
        create_name_function(&mut res, "group", &group_names);
        build_parser_qbe(self, &mut res);
        res
    }
}

pub fn build_parser_from_src(parser_file: &Path) -> ParserBuilder {
    let parser_text = fs::read_to_string(parser_file).unwrap();
    let res = Gibberish::parse(&parser_text);
    let parser_filename = parser_file.to_str().unwrap();
    report_errors(&res, &parser_text, parser_filename, &Gibberish);
    let dsl_ast = RootAst(res.as_group());
    let mut state = CheckState::default();
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
    });
    if has_err {
        panic!("Failed to build parser due to previous errors")
    } else {
        let mut builder = ParserBuilder::new(parser_text, parser_filename.to_string());
        dsl_ast.build_parser(&mut builder);
        builder
    }
}

pub fn build_static_lib(qbe_text: &str, out: &Path) {
    let qbe = NamedTempFile::new().unwrap();
    let qbe_path = qbe.path().to_path_buf();

    let lib = Builder::new().suffix(".s").tempfile().unwrap();
    let lib_path = lib.path().to_path_buf();

    let lib_o = Builder::new().suffix(".o").tempfile().unwrap();
    let lib_o_path = lib_o.path().to_path_buf();

    fs::write(&qbe_path, qbe_text).unwrap();
    Command::new("qbe")
        .arg("-o")
        .arg(&lib_path)
        .arg(&qbe_path)
        .status()
        .unwrap();
    Command::new("cc")
        .arg("-g")
        .arg("-fno-omit-frame-pointer")
        .arg("-c")
        // .arg("-fPIC")
        .arg(&lib_path)
        .arg("-o")
        .arg(&lib_o_path)
        .status()
        .unwrap();
    Command::new("ar")
        .arg("rcs")
        .arg(out)
        .arg(&lib_o_path)
        .status()
        .unwrap();
}

pub fn build_dynamic_lib(qbe_path: &Path, out: &Path) {
    let lib = Builder::new().suffix(".s").tempfile().unwrap();
    let lib_path = lib.path().to_path_buf();

    let obj = Builder::new().suffix(".o").tempfile().unwrap();
    let obj_path = obj.path().to_path_buf();
    Command::new("qbe")
        .arg("-o")
        .arg(&lib_path)
        .arg(qbe_path)
        .status()
        .unwrap();

    Command::new("cc")
        .arg("-c")
        .arg("-fPIC")
        .arg(&lib_path)
        .arg("-o")
        .arg(&obj_path)
        .status()
        .unwrap();

    Command::new("cc")
        .arg("-shared")
        .arg("-o")
        .arg(out)
        .arg(&obj_path)
        .status()
        .unwrap();
}
