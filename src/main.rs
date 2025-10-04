use clap::Parser;
use cli::command::Command;

mod api;
mod cli;
mod giblang;
#[cfg(test)]
mod json;
mod lsp;
pub mod parser;

#[tokio::main]
async fn main() {
    Command::parse().run().await;
}
