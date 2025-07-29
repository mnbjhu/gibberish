use clap::Parser;
use cli::command::Command;

mod api;
mod cli;
mod dsl;
#[cfg(test)]
mod json;
pub mod lexer;
pub mod parser;

fn main() {
    Command::parse().run();
}
