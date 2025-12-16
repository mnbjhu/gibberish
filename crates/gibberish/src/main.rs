use clap::Parser;
use cli::command::Command;

mod ast;
mod cli;
mod lexer;
mod parser;
mod report;

#[tokio::main]
async fn main() {
    Command::parse().run().await;
}
