use std::{
    fs::{self, OpenOptions},
    path::Path,
};

use crate::json::parser::json_parser;

pub fn parse(path: &Path) {
    let log = OpenOptions::new()
        .write(true)
        .create(true)
        .truncate(true)
        .open("out.log")
        .unwrap();
    tracing_subscriber::fmt()
        .with_writer(log)
        .with_ansi(false)
        .init();
    let text = fs::read_to_string(path).unwrap();
    let res = json_parser().parse(&text);
    res.debug_print();
}
