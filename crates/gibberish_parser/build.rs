
fn main() {{
    println!("cargo:rerun-if-changed=lib/parser.c");

    cc::Build::new()
        .file("lib/parser.c")
        .compile("gibberish-parser");
}}
