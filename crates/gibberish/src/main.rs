use clap::Parser;
use cli::command::Command;

mod ast;
mod build;
mod cli;
mod lexer;
mod lsp;
mod parser;
mod report;

#[tokio::main]
async fn main() {
    Command::parse().run().await;
}
