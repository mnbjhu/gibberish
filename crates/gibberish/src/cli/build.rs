use std::cmp::Ordering;
use std::fmt::Write as _;
use std::process::{Command, exit};
use std::{fs, path::Path};

use ansi_term::Color;
use gibberish_gibberish_parser::Gibberish;
use tempfile::Builder;
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

fn ext_eq(path: &Path, ext: &str) -> bool {
    path.extension()
        .and_then(|e| e.to_str())
        .is_some_and(|e| e.eq_ignore_ascii_case(ext))
}

impl BuildKind {
    pub fn from_path(path: &Path) -> Self {
        if ext_eq(path, DYN_LIB_EXT) {
            return BuildKind::Dynamic;
        }
        if ext_eq(path, STATIC_LIB_EXT) {
            return BuildKind::Static;
        }
        if ext_eq(path, C_EXT) {
            return BuildKind::C;
        }

        let got = path
            .extension()
            .and_then(|e| e.to_str())
            .unwrap_or("<no extension>");

        panic!(
            "File format not supported: got .{}; expected output file ending .{}, .{} or .{}",
            got, DYN_LIB_EXT, STATIC_LIB_EXT, C_EXT
        )
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
            fs::write(&c, res).unwrap();
            let c_path = c.into_temp_path();
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
        ) => span.start().cmp(&other_span.start()),
        (CheckError::Unused(span), CheckError::Unused(other_span)) => {
            span.start().cmp(&other_span.start())
        }
        (
            CheckError::Redeclaration { this: span, .. },
            CheckError::Redeclaration {
                this: other_span, ..
            },
        ) => span.start().cmp(&other_span.start()),
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

fn obj_suffix() -> &'static str {
    #[cfg(windows)]
    {
        ".obj"
    }
    #[cfg(not(windows))]
    {
        ".o"
    }
}

pub fn build_static_lib(c_text: &str, out: &Path) {
    let c_file = Builder::new().suffix(".c").tempfile().unwrap();
    let c_path = c_file.path().to_path_buf();

    let obj_file = Builder::new().suffix(obj_suffix()).tempfile().unwrap();
    let obj_path = obj_file.path().to_path_buf();

    fs::write(&c_path, c_text).unwrap();

    compile_c_to_object(&c_path, &obj_path, false);
    archive_static(&obj_path, out);
}

pub fn build_dynamic_lib(c_path: &Path, out: &Path) {
    let obj_file = Builder::new().suffix(obj_suffix()).tempfile().unwrap();
    let obj_path = obj_file.into_temp_path();
    compile_c_to_object(c_path, &obj_path, /*pic*/ true);
    link_shared(&obj_path, out);
}

fn compile_c_to_object(c_path: &Path, obj_path: &Path, pic: bool) {
    #[cfg(all(windows, target_env = "msvc"))]
    {
        let mut cmd = Command::new("cl.exe");
        cmd.arg("/nologo")
            .arg("/c")
            .arg("/Zi")
            .arg("/Od")
            .arg("/Fo:".to_string() + obj_path.to_string_lossy().as_ref())
            .arg(c_path);

        let status = cmd.status().unwrap();
        assert!(status.success(), "cl.exe /c failed");
    }

    #[cfg(not(all(windows, target_env = "msvc")))]
    {
        let mut cmd = Command::new("cc");
        cmd.arg("-g").arg("-fno-omit-frame-pointer").arg("-c");
        if pic {
            cmd.arg("-fPIC");
        }
        cmd.arg(c_path).arg("-o").arg(obj_path);
        let status = cmd.status().unwrap();
        assert!(status.success(), "cc -c failed");
    }
}

fn archive_static(obj_path: &Path, out: &Path) {
    #[cfg(all(windows, target_env = "msvc"))]
    {
        let status = Command::new("lib.exe")
            .arg("/nologo")
            .arg(format!("/OUT:{}", out.to_string_lossy()))
            .arg(obj_path)
            .status()
            .unwrap();
        assert!(status.success(), "lib.exe failed");
    }

    #[cfg(not(all(windows, target_env = "msvc")))]
    {
        let status = Command::new("ar")
            .arg("rcs")
            .arg(out)
            .arg(obj_path)
            .status()
            .unwrap();
        assert!(status.success(), "ar failed");
    }
}

fn link_shared(obj_path: &Path, out: &Path) {
    #[cfg(target_os = "macos")]
    {
        let status = Command::new("cc")
            .arg("-dynamiclib")
            .arg("-o")
            .arg(out)
            .arg(obj_path)
            .status()
            .unwrap();
        assert!(status.success(), "cc -dynamiclib failed");
    }

    #[cfg(target_os = "linux")]
    {
        let status = Command::new("cc")
            .arg("-shared")
            .arg("-o")
            .arg(out)
            .arg(obj_path)
            .status()
            .unwrap();
        assert!(status.success(), "cc -shared failed");
    }

    #[cfg(all(windows, target_env = "msvc"))]
    {
        let status = Command::new("link.exe")
            .arg("/nologo")
            .arg("/DLL")
            .arg(format!("/OUT:{}", out.to_string_lossy()))
            .arg(obj_path)
            .status()
            .unwrap();
        assert!(status.success(), "link.exe /DLL failed");
    }

    #[cfg(all(windows, not(target_env = "msvc")))]
    {
        let status = Command::new("cc")
            .arg("-shared")
            .arg("-o")
            .arg(out)
            .arg(obj_path)
            .status()
            .unwrap();
        assert!(status.success(), "cc -shared failed (windows gnu)");
    }
}
