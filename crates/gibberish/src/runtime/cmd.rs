use std::{
    collections::HashMap,
    fs,
    io::Write as _,
    io::stdout,
    path::{Path, PathBuf},
};

use repl_rs::{Command, Convert as _, Parameter, Repl, Value};
use tracing::debug;

use crate::runtime::{
    LexerParserState,
    lexer::edit::TextEdit,
    lsp::{build_parser_from_file, start_lsp},
    parser::res::Res,
};

#[derive(clap::Subcommand, Debug)]
pub enum RuntimeCommand {
    /// Lexes a file
    Lex {
        /// The file to lex
        src: PathBuf,

        /// The parser to lex the file with (uses the gibberish parser if unset)
        #[clap(short, long)]
        parser: PathBuf,
    },

    /// Parses a file and shows the LST
    Parse {
        /// The file to parse
        src: PathBuf,
        /// Path to a parser to use
        #[clap(short, long)]
        parser: PathBuf,
    },
    Lsp {
        /// Path to a parser to use
        parser: PathBuf,
    },
    Repl {
        /// Path to a parser to use
        parser: PathBuf,
    },
}

impl RuntimeCommand {
    pub fn run(&self) {
        debug!("Running {self:?}");
        match self {
            RuntimeCommand::Lex { src, parser } => {
                let builder = build_parser_from_file(parser);
                let text = fs::read_to_string(src).unwrap();
                let state = LexerParserState::new(text, &builder);
                for tok in state.lexer_state.tokens {
                    println!("{}", state.lexer.name_by_id(tok.kind))
                }
            }
            RuntimeCommand::Parse { src, parser } => {
                let builder = build_parser_from_file(parser);
                let text = fs::read_to_string(src).unwrap();
                let state = LexerParserState::new(text, &builder);
                match &state.node {
                    Res::Ok(node) => node.fmt_at(&mut stdout(), 0, 0, &state).unwrap(),
                    Res::Break(_) => todo!(),
                    Res::Err => todo!(),
                }
            }
            RuntimeCommand::Lsp { parser } => {
                start_lsp(parser);
            }
            RuntimeCommand::Repl { parser } => {
                repl(parser).unwrap();
            }
        }
    }
}

fn repl(parser: &Path) -> Result<(), repl_rs::Error> {
    let builder = build_parser_from_file(parser);
    let mut repl = Repl::new(LexerParserState::new(String::new(), &builder))
        .with_name("gibberish")
        .with_version("v0.1.0")
        .with_description("Gibberish REPL")
        .add_command(
            Command::new("text", get_text).with_help("Prints the text of the current parse"),
        )
        .add_command(Command::new("lex", lex).with_help("Prints the tokens of the current parse"))
        .add_command(Command::new("tree", tree).with_help("Prints the tree of the current parse"))
        .add_command(
            Command::new("parse", parse)
                .with_parameter(Parameter::new("text").set_required(true)?)?
                .with_help("Parse a new text"),
        )
        .add_command(
            Command::new("load", load)
                .with_parameter(Parameter::new("file").set_required(true)?)?
                .with_help("Parse the text from a file"),
        )
        .add_command(
            Command::new("edit", edit)
                .with_parameter(Parameter::new("start").set_required(true)?)?
                .with_parameter(Parameter::new("end").set_required(true)?)?
                .with_parameter(Parameter::new("insert").set_required(true)?)?
                .with_help("Edit the parsed text"),
        );
    repl.run()
}

fn parse(
    args: HashMap<String, Value>,
    context: &mut LexerParserState,
) -> Result<Option<String>, repl_rs::Error> {
    let text: String = args["text"].convert()?;
    context.parse(text);
    Ok(None)
}

fn load(
    args: HashMap<String, Value>,
    context: &mut LexerParserState,
) -> Result<Option<String>, repl_rs::Error> {
    let file: String = args["file"].convert()?;
    let text = fs::read_to_string(file).unwrap();
    context.parse(text);
    Ok(None)
}

fn edit(
    args: HashMap<String, Value>,
    context: &mut LexerParserState,
) -> Result<Option<String>, repl_rs::Error> {
    let start: usize = args["start"].convert()?;
    let end: usize = args["end"].convert()?;
    let insert: String = args["insert"].convert()?;
    let stats = context.edit(&TextEdit {
        remove: start..end,
        text: insert,
    });
    Ok(Some(format!("{stats:#?}")))
}

fn lex(
    _: HashMap<String, Value>,
    context: &mut LexerParserState,
) -> Result<Option<String>, repl_rs::Error> {
    let mut buf = Vec::new();
    for tok in &context.lexer_state.tokens {
        writeln!(&mut buf, "{}", context.lexer.name_by_id(tok.kind)).unwrap();
    }
    Ok(Some(String::from_utf8(buf).unwrap()))
}

fn get_text(
    _: HashMap<String, Value>,
    context: &mut LexerParserState,
) -> Result<Option<String>, repl_rs::Error> {
    Ok(Some(context.lexer_state.text.clone()))
}

fn tree(
    _: HashMap<String, Value>,
    context: &mut LexerParserState,
) -> Result<Option<String>, repl_rs::Error> {
    match &context.node {
        Res::Ok(node) => {
            let mut buf = Vec::new();
            node.fmt_at(&mut buf, 0, 0, context).unwrap();
            let res = String::from_utf8(buf).unwrap();
            Ok(Some(res))
        }
        res => Ok(Some(format!("{res:?}"))),
    }
}
