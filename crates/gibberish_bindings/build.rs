fn main() {
    // Point Cargo at the folder containing your lib
    println!("cargo:rustc-link-search=native=crates/gibberish_bindings/qbe");
    // Link the static lib: libqbeadd.a  -> name = "qbeadd"
    // println!("cargo:rustc-link-lib=static=qbetest");
    // If you built a shared lib instead, use:
    // println!("cargo:rustc-link-lib=dylib=qbeadd");
}
