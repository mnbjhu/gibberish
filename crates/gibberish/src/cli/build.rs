use std::process::Command;
use std::{fs, path::Path};

use tempfile::{Builder, NamedTempFile};

use crate::dsl::build::build_parser_qbe;

use crate::dsl::lexer::build::create_name_function;
use crate::{
    api::ptr::ParserCache,
    dsl::{
        ast::RootAst,
        lexer::{RuntimeLang, build::build_lexer_qbe, build_lexer},
        lst::{dsl_parser, lang::DslLang, syntax::DslSyntax},
        parser::{ParserBuilder, build_parser},
    },
};

#[derive(Clone, clap::ValueEnum)]
pub enum BuildKind {
    Qbe,
    Static,
    Dynamic,
}

pub fn build(parser_file: &Path, output: Option<&Path>, kind: &BuildKind) {
    let mut d_cache = ParserCache::new(DslLang);
    let d_parser = dsl_parser(&mut d_cache);
    let parser_text = fs::read_to_string(parser_file).unwrap();
    let dsl_lst = d_parser.parse(&parser_text, &d_cache);
    let dsl_ast = RootAst(dsl_lst.as_group());
    assert_eq!(dsl_lst.as_group().kind, DslSyntax::Root);
    let parser_filename = parser_file.to_str().unwrap();
    let lexer = build_lexer(dsl_ast, &parser_text, parser_filename);
    let lang = RuntimeLang {
        lexer,
        vars: vec![],
    };

    let mut builder = ParserBuilder::new(lang, &parser_text, parser_filename);
    let parser = build_parser(dsl_ast, &mut builder);
    builder.cache.lang.vars = builder.vars;
    let mut group_names = builder
        .cache
        .lang
        .vars
        .iter()
        .map(|it| it.0.as_str())
        .collect::<Vec<_>>();
    group_names.push("root");

    let mut res = String::new();
    build_lexer_qbe(dsl_ast, &parser_text, parser_filename, &mut res);
    build_parser_qbe(&parser, &builder.cache, &mut res);
    create_name_function(&mut res, "group", &group_names);

    if let Some(out) = output {
        match kind {
            BuildKind::Qbe => fs::write(out, res).unwrap(),
            BuildKind::Static => {
                let qbe = NamedTempFile::new().unwrap();
                let qbe_path = qbe.path().to_path_buf();

                let lib = Builder::new().suffix(".s").tempfile().unwrap();
                let lib_path = lib.path().to_path_buf();

                fs::write(&qbe_path, res).unwrap();
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
                    .arg(out)
                    .status()
                    .unwrap();
            }
            BuildKind::Dynamic => {
                let qbe = NamedTempFile::new().unwrap();
                let qbe_path = qbe.path().to_path_buf();

                let lib = Builder::new().suffix(".s").tempfile().unwrap();
                let lib_path = lib.path().to_path_buf();

                let obj = Builder::new().suffix(".o").tempfile().unwrap();
                let obj_path = obj.path().to_path_buf();
                fs::write(&qbe_path, res).unwrap();
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
        }
    } else {
        println!("{}", res);
    }
}
