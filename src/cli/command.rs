use std::path::PathBuf;

use super::lex::lex;

#[derive(clap::Parser)]
pub enum Command {
    /// Lexes a file
    Lex { path: PathBuf },

    /// Lexes a file
    Parse { path: PathBuf },
}

impl Command {
    pub fn run(&self) {
        match self {
            Command::Lex { path } => lex(path),
            Command::Parse { path } => todo!(),
        }
    }
}
