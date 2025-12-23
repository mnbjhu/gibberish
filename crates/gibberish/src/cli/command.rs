use std::path::PathBuf;

// use crate::cli::lsp::lsp;

use tower_lsp::lsp_types::DiagnosticSeverity;
use tracing_subscriber::layer::SubscriberExt as _;
use tracing_subscriber::util::SubscriberInitExt as _;
use tracing_subscriber::{EnvFilter, fmt};

use crate::cli::build::build;
use crate::cli::generate::generate;
use crate::cli::lex::lex_custom;
use crate::cli::parse::parse_custom;
use crate::cli::watch::watch_custom;
use crate::lsp::start_lsp;

use super::{lex::lex, parse::parse, watch::watch};

#[derive(Default, Clone, clap::ValueEnum)]
pub enum Severity {
    Error,
    #[default]
    Warning,
    Info,
}

impl From<&Severity> for DiagnosticSeverity {
    fn from(value: &Severity) -> Self {
        match value {
            Severity::Error => DiagnosticSeverity::ERROR,
            Severity::Warning => DiagnosticSeverity::WARNING,
            Severity::Info => DiagnosticSeverity::INFORMATION,
        }
    }
}

/// Gibberish Compiler - Tools for building, testing and working with Gibberish parsers
#[derive(clap::Parser)]
pub enum Command {
    /// Lexes a file
    Lex {
        /// The file to lex
        src: PathBuf,

        /// The parser to lex the file with (uses the gibberish parser if unset)
        #[clap(short, long)]
        parser: Option<PathBuf>,

        /// The minimum severity for an error to be reported
        #[clap(long, value_enum, default_value_t = Severity::default())]
        min_severity: Severity,
    },

    /// Parses a file and shows the LST
    Parse {
        /// The file to parse
        path: PathBuf,

        /// Hide errors from the LST
        #[clap(short('e'), long)]
        hide_errors: bool,

        /// Hide tokens from the LST
        #[clap(short('t'), long)]
        hide_tokens: bool,

        /// Path to a parser to use (uses the gibberish parser if unset)
        #[clap(short, long)]
        parser: Option<PathBuf>,

        /// The minimum severity for an error to be reported
        #[clap(long, value_enum, default_value_t = Severity::default())]
        min_severity: Severity,
    },

    /// Watches a file, parses it and shows the LST as it changes
    Watch {
        /// The file to watch
        path: PathBuf,

        /// Hide errors from the LST
        #[clap(short('e'), long)]
        hide_errors: bool,

        /// Hide tokens from the LST
        #[clap(short('t'), long)]
        hide_tokens: bool,

        /// Path to a parser to use (uses the gibberish parser if unset)
        #[clap(short, long)]
        parser: Option<PathBuf>,

        /// The minimum severity for an error to be reported
        #[clap(long, value_enum, default_value_t = Severity::default())]
        min_severity: Severity,
    },

    /// Builds a parser from a .gib file
    Build {
        /// Path to a parser to build
        path: PathBuf,
        /// Path to output the comiled library (static lib/dynamic lib/qbe)
        #[clap(short, long)]
        output: PathBuf,

        /// The minimum severity for an error to be reported
        #[clap(long, value_enum, default_value_t = Severity::default())]
        min_severity: Severity,
    },

    /// Generate libraries and api's for parser
    Generate {
        /// Path to a parser to build
        path: PathBuf,
    },

    /// Start the Gibberish language server
    Lsp,
}

impl Command {
    pub async fn run(&self) {
        if !matches!(&self, Command::Lsp) {
            let fmt_layer = fmt::layer().with_target(false);
            let filter_layer = EnvFilter::try_from_default_env()
                .or_else(|_| EnvFilter::try_new("info"))
                .unwrap();

            tracing_subscriber::registry()
                .with(filter_layer)
                .with(fmt_layer)
                .init();
        }

        match self {
            Command::Lex {
                src: path,
                parser: parser_src,
                min_severity,
            } => {
                if let Some(parser_src) = parser_src {
                    lex_custom(path, parser_src, min_severity.into())
                } else {
                    lex(path)
                }
            }
            Command::Parse {
                path,
                hide_errors,
                hide_tokens,
                parser: parser_src,
                min_severity,
            } => {
                if let Some(parser_src) = parser_src {
                    parse_custom(
                        path,
                        !hide_errors,
                        !hide_tokens,
                        parser_src,
                        min_severity.into(),
                    )
                } else {
                    parse(path, !hide_errors, !hide_tokens)
                }
            }
            Command::Watch {
                path,
                hide_errors,
                hide_tokens,
                parser: parser_src,
                min_severity,
            } => {
                if let Some(src) = parser_src {
                    watch_custom(path, !hide_errors, !hide_tokens, src, min_severity.into())
                        .unwrap()
                } else {
                    watch(path, !hide_errors, !hide_tokens).unwrap()
                }
            }
            Command::Build {
                path,
                output,
                min_severity,
            } => build(path, output, min_severity.into()),
            Command::Generate { path } => generate(path),
            Command::Lsp => start_lsp().await,
        }
    }
}
