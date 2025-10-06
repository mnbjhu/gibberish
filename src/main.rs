use clap::Parser;
use cli::command::Command;

mod api;
mod cli;
mod json;
mod parser;

#[tokio::main]
async fn main() {
    Command::parse().run().await;
}
