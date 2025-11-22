mod parse;

use std::path::PathBuf;

use crate::cli::parse::parse;

#[derive(clap::Parser)]
pub enum Command {
    Parse { parser: PathBuf, text: PathBuf },
}

impl Command {
    pub fn run(&self) {
        match self {
            Command::Parse { parser, text } => parse(parser, text),
        }
    }
}
