use std::path::PathBuf;

// use crate::cli::lsp::lsp;

use super::{lex::lex, parse::parse, watch::watch};

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

    /// Show the generate LST for a file as it changes
    Watch {
        path: PathBuf,
        #[clap(short('e'), long)]
        hide_errors: bool,
        #[clap(short('t'), long)]
        hide_tokens: bool,
    },
}

impl Command {
    pub async fn run(&self) {
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
        }
    }
}
