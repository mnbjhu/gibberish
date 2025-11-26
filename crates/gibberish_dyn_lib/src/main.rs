use clap::Parser;

use crate::cli::Command;

mod bindings;
mod cli;

fn main() {
    Command::parse().run();
}
