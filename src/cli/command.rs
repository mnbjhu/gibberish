use std::path::PathBuf;

use super::{build::build, check::check, lex::lex, parse::parse, watch::watch};

#[derive(clap::Parser)]
pub enum Command {
    /// Lexes a file
    Lex { path: PathBuf },

    /// Parses a file
    Parse {
        path: PathBuf,
        #[clap(short('e'), long)]
        hide_errors: bool,
        #[clap(short('t'), long)]
        hide_tokens: bool,
    },

    /// Watches a file for changes and prints the parser output
    Watch {
        path: PathBuf,
        #[clap(short('e'), long)]
        hide_errors: bool,
        #[clap(short('t'), long)]
        hide_tokens: bool,
    },

    /// Checks the file for errors
    Check { path: PathBuf },

    /// Builds a parser from a file
    Build {
        parser_path: PathBuf,
        lex_path: PathBuf,
    },
}

impl Command {
    pub fn run(&self) {
        match self {
            Command::Lex { path } => lex(path),
            Command::Parse {
                path,
                hide_errors,
                hide_tokens,
            } => parse(path, !hide_errors, !hide_tokens),
            Command::Watch {
                path,
                hide_errors,
                hide_tokens,
            } => watch(path, !hide_errors, !hide_tokens).unwrap(),
            Command::Check { path } => check(path),
            Command::Build {
                parser_path,
                lex_path,
            } => build(parser_path, lex_path),
        }
    }
}
