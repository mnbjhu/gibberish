use clap::Parser;
use cli::command::Command;

mod cli;
mod dsl;
mod json;
mod parser;

fn main() {
    Command::parse().run();
}
