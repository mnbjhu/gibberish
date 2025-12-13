use std::path::PathBuf;

// use crate::cli::lsp::lsp;

use tracing_subscriber::layer::SubscriberExt as _;
use tracing_subscriber::util::SubscriberInitExt as _;
use tracing_subscriber::{EnvFilter, fmt};

use crate::cli::build::build;
use crate::cli::generate::generate;
use crate::cli::lex::lex_custom;
use crate::cli::parse::parse_custom;
use crate::cli::watch::watch_custom;

use super::{lex::lex, parse::parse, watch::watch};

#[derive(clap::Parser)]
pub enum Command {
    /// Lexes a file
    Lex {
        src: PathBuf,

        #[clap(short, long)]
        parser: Option<PathBuf>,
    },

    /// Parses a file and shows the generated LST
    Parse {
        path: PathBuf,
        #[clap(short('e'), long)]
        hide_errors: bool,
        #[clap(short('t'), long)]
        hide_tokens: bool,
        #[clap(short, long)]
        parser: Option<PathBuf>,
    },

    /// Watches a file, parses it and shows the generated LST
    Watch {
        path: PathBuf,
        #[clap(short('e'), long)]
        hide_errors: bool,
        #[clap(short('t'), long)]
        hide_tokens: bool,
        #[clap(short, long)]
        parser: Option<PathBuf>,
    },

    /// Builds a parser
    Build {
        path: PathBuf,
        #[clap(short, long)]
        output: Option<PathBuf>,
    },

    /// Generate libraries and api's for parser
    Generate { path: PathBuf },
}

impl Command {
    pub async fn run(&self) {
        let fmt_layer = fmt::layer().with_target(false);
        let filter_layer = EnvFilter::try_from_default_env()
            .or_else(|_| EnvFilter::try_new("info"))
            .unwrap();

        tracing_subscriber::registry()
            .with(filter_layer)
            .with(fmt_layer)
            .init();

        match self {
            Command::Lex {
                src: path,
                parser: parser_src,
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
                parser: parser_src,
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
                parser: parser_src,
            } => {
                if let Some(src) = parser_src {
                    watch_custom(path, !hide_errors, !hide_tokens, src).unwrap()
                } else {
                    watch(path, !hide_errors, !hide_tokens).unwrap()
                }
            }
            Command::Build { path, output } => build(path, output.as_ref().map(PathBuf::as_path)),
            Command::Generate { path } => generate(path),
        }
    }
}
