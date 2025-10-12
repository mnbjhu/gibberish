use clap::Parser;
use cli::command::Command;

mod api;
mod cli;
mod dsl;
mod json;
mod lsp;
mod parser;
mod query;
mod report;

#[tokio::main]
async fn main() {
    Command::parse().run().await;
}
