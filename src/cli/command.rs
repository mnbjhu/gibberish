use std::path::PathBuf;

// use crate::cli::lsp::lsp;

use crate::cli::build::build;
use crate::cli::parse::parse_custom;
use crate::cli::query::query;
use crate::{cli::lex::lex_custom, lsp::main_loop};

use super::{lex::lex, parse::parse, watch::watch};

#[derive(clap::Parser)]
pub enum Command {
    /// Lexes a file
    Lex {
        #[clap(long)]
        src: PathBuf,

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

    Query {
        #[clap(long)]
        src: PathBuf,
        #[clap(long)]
        parser_src: PathBuf,
        query: String,
    },

    /// Starts an lsp for the specified syntax file
    Lsp { path: PathBuf },

    /// Builds a parser
    Build { path: PathBuf },
}

impl Command {
    pub async fn run(&self) {
        match self {
            Command::Lex {
                src: path,
                parser_src,
            } => {
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
            Command::Lsp { path } => main_loop(path).await,
            Command::Query {
                src,
                parser_src,
                query: q,
            } => {
                query(parser_src, src, q);
            }
            Command::Build { path } => build(path),
        }
    }
}
