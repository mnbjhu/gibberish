mod lex;
mod parse;
mod watch;

use std::path::PathBuf;

use crate::cli::{lex::lex, parse::parse, watch::watch};

#[derive(clap::Parser)]
pub enum Command {
    Lex { parser: PathBuf, text: PathBuf },
    Parse { parser: PathBuf, text: PathBuf },
    Watch { parser: PathBuf, text: PathBuf },
}

impl Command {
    pub fn run(&self) {
        match self {
            Command::Parse { parser, text } => parse(parser, text),
            Command::Watch { parser, text } => watch(parser, text, true, true).unwrap(),
            Command::Lex { parser, text } => lex(parser, text),
        }
    }
}
