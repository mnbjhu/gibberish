use clap::Parser;
use cli::command::Command;

mod ast;
mod cli;
mod lexer;
mod lsp;
mod parser;
mod report;
mod runtime;

fn apply_operation<F>(x: i32, y: i32, op: F) -> i32
where
    F: Fn(i32, i32) -> i32,
{
    op(x, y)
}

fn add(a: i32, b: i32) -> i32 {
    a + b
}

fn multiply(a: i32, b: i32) -> i32 {
    a * b
}

#[tokio::main]
async fn main() {
    let result1 = apply_operation(5, 3, add);
    let result2 = apply_operation(5, 3, multiply);
    let result3 = apply_operation(5, 3, |a, b| a - b);

    println!("Results: {} {} {}", result1, result2, result3);

    Command::parse().run().await;
}
