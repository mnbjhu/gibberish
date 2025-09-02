use clap::Parser;
use cli::command::Command;

mod api;
mod cli;
mod giblang;
#[cfg(test)]
mod json;
pub mod lexer;
pub mod parser;

fn main() {
    Command::parse().run();
}
