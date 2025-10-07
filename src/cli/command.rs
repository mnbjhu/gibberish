use std::path::PathBuf;

// use crate::cli::lsp::lsp;

use crate::cli::{lex::lex_custom, parse::parse_custom};

use super::{lex::lex, parse::parse, watch::watch};

#[derive(clap::Parser)]
pub enum Command {
    /// Lexes a file
    Lex {
        path: PathBuf,

        #[clap(long)]
        parser_src: Option<PathBuf>,
    },

    /// Parses a file
    Parse {
        path: PathBuf,
        #[clap(short('e'), long)]
        hide_errors: bool,
        #[clap(short('t'), long)]
        hide_tokens: bool,
        #[clap(long)]
        parser_src: Option<PathBuf>,
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
            Command::Lex { path, parser_src } => {
                if let Some(parser_src) = parser_src {
                    lex_custom(path, parser_src)
                } else {
                    lex(path)
                }
            }
            Command::Parse {
                path,
                hide_errors,
                hide_tokens,
                parser_src,
            } => {
                if let Some(parser_src) = parser_src {
                    parse_custom(path, !hide_errors, !hide_tokens, parser_src)
                } else {
                    parse(path, !hide_errors, !hide_tokens)
                }
            }
            Command::Watch {
                path,
                hide_errors,
                hide_tokens,
            } => watch(path, !hide_errors, !hide_tokens).unwrap(),
        }
    }
}
