use std::fmt::Write as _;
use std::process::Command;
use std::{fs, path::Path};

use gibberish_gibberish_parser::Gibberish;
use tempfile::{Builder, NamedTempFile};

use crate::ast::builder::ParserBuilder;
use crate::parser::build::build_parser_qbe;
use crate::parser::ptr::ParserIndex;

use crate::ast::RootAst;
use crate::lexer::build::create_name_function;
use crate::report::{report_errors, report_parse_error};

#[derive(Clone, clap::ValueEnum)]
pub enum BuildKind {
    Qbe,
    Static,
    Dynamic,
}

pub fn build(parser_file: &Path, output: Option<&Path>, kind: &BuildKind) {
    let res = build_qbe_str(parser_file);
    if let Some(out) = output {
        match kind {
            BuildKind::Qbe => fs::write(out, res).unwrap(),
            BuildKind::Static => {
                build_static_lib(&res, out);
            }
            BuildKind::Dynamic => {
                build_dynamic_lib(&res, out);
            }
        }
    } else {
        println!("{}", res);
    }
}

pub fn build_qbe_str(parser_file: &Path) -> String {
    let (builder, parser) = build_parser_from_src(parser_file);
    builder.build_qbe(parser)
}

impl ParserBuilder {
    pub fn build_qbe(&self, parser: ParserIndex) -> String {
        let mut group_names = self.vars.iter().map(|it| it.0.as_str()).collect::<Vec<_>>();
        group_names.push("root");
        group_names.push("unmatched");
        let mut res = String::new();
        let pre = include_str!("../../pre.qbe");
        write!(&mut res, "{}", pre).unwrap();
        build_parser_qbe(&parser, self, &mut res);
        create_name_function(&mut res, "group", &group_names);
        res
    }
}

pub fn build_parser_from_src(parser_file: &Path) -> (ParserBuilder, ParserIndex) {
    let parser_text = fs::read_to_string(parser_file).unwrap();
    let res = Gibberish::parse(&parser_text);
    let parser_filename = parser_file.to_str().unwrap();
    report_errors(&res, &parser_text, parser_filename, &Gibberish);
    let dsl_ast = RootAst(res.as_group());
    let mut builder = ParserBuilder::new(parser_text, parser_filename.to_string());
    let parser = dsl_ast.build_parser(&mut builder);
    (builder, parser)
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
        .arg("-c")
        .arg("-fPIC")
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

pub fn build_dynamic_lib(qbe_text: &str, out: &Path) {
    let qbe = NamedTempFile::new().unwrap();
    let qbe_path = qbe.path().to_path_buf();

    let lib = Builder::new().suffix(".s").tempfile().unwrap();
    let lib_path = lib.path().to_path_buf();

    let obj = Builder::new().suffix(".o").tempfile().unwrap();
    let obj_path = obj.path().to_path_buf();
    fs::write(&qbe_path, qbe_text).unwrap();
    Command::new("qbe")
        .arg("-o")
        .arg(&lib_path)
        .arg(&qbe_path)
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
