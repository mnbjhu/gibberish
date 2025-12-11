fn main() {
    println!("cargo:rustc-link-search=native=crates/gibberish_parser/lib");
    println!("cargo:rustc-link-lib=static=gibberish-parser");
}
