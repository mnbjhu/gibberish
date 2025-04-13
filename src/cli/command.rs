use std::path::PathBuf;

use super::{lex::lex, parse::parse};

#[derive(clap::Parser)]
pub enum Command {
    /// Lexes a file
    Lex { path: PathBuf },

    /// Parses a file
    Parse { path: PathBuf },
}

impl Command {
    pub fn run(&self) {
        match self {
            Command::Lex { path } => lex(path),
            Command::Parse { path } => parse(path),
        }
    }
}
