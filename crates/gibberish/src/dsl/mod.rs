use std::{fs, path::Path};

use gibberish_gibberish_parser::Gibberish;

use crate::{
    api::ptr::{ParserCache, ParserIndex},
    dsl::{
        ast::RootAst,
        lexer::{RuntimeLang, build_lexer},
        parser::{ParserBuilder, build_parser},
    },
    report::report_errors,
};

pub mod ast;
pub mod build;
pub mod lexer;
pub mod parser;
pub mod regex;
