
// build.rs
//
// Builds a static library from a C source at lib/parser.c and links it into this crate.
// Assumes a C toolchain is available on PATH.
// - Unix: uses `ar` to create lib<basename>.a
// - Windows MSVC: uses `lib.exe` to create <basename>.lib (requires MSVC tools)
// - Windows GNU (MinGW): uses `ar` (still produces .a)

use std::{
    env,
    path::{Path, PathBuf},
    process::Command,
};

fn main() {
    // ---- inputs ----
    let c_src = Path::new("lib/parser.c");
    println!("cargo:rerun-if-changed={}", c_src.display());

    // Optional: if you have a header and want rebuilds when it changes
    let c_hdr = Path::new("lib/parser.h");
    if c_hdr.exists() {
        println!("cargo:rerun-if-changed={}", c_hdr.display());
    }

    // ---- environment ----
    let target = env::var("TARGET").expect("TARGET not set");
    let out_dir = PathBuf::from(env::var("OUT_DIR").expect("OUT_DIR not set"));

    // Parameterised static library basename (no "lib" prefix, no extension)
    let lib_basename: &str = "gibberish-parser";

    // ---- derived paths ----
    let obj_path = if target.contains("windows") {
        out_dir.join("parser.obj")
    } else {
        out_dir.join("parser.o")
    };

    let lib_path = static_lib_filename(&out_dir, &target, lib_basename);

    // ---- 1) CC: C -> object ----
    let cc = env::var("CC").unwrap_or_else(|_| "cc".to_string());

    let mut cc_cmd = Command::new(cc);
    cc_cmd.arg("-c").arg(&c_src).arg("-o").arg(&obj_path);

    // If your C file includes headers from lib/, add include path:
    cc_cmd.arg("-I").arg("lib");

    if !target.contains("windows") {
        cc_cmd.arg("-fPIC");
    }

    // Keep your previous debug-ish flags; adjust as desired.
    cc_cmd.arg("-g").arg("-fno-omit-frame-pointer");

    // If you want C standard selection, uncomment:
    // cc_cmd.arg("-std=c11");

    run_cmd(cc_cmd);

    // ---- 2) Archive: object -> static library ----
    if target.contains("windows-msvc") {
        let lib_tool = env::var("LIB").unwrap_or_else(|_| "lib".to_string());
        let out_flag = format!("/OUT:{}", lib_path.to_str().unwrap());
        run(&lib_tool, &[&out_flag, obj_path.to_str().unwrap()]);
    } else {
        let ar = env::var("AR").unwrap_or_else(|_| "ar".to_string());
        run(
            &ar,
            &[
                "rcs",
                lib_path.to_str().unwrap(),
                obj_path.to_str().unwrap(),
            ],
        );
    }

    // ---- 3) Tell Cargo/rustc how to link it ----
    println!("cargo:rustc-link-search=native={}", out_dir.display());
    println!("cargo:rustc-link-lib=static={}", lib_basename);
}

fn static_lib_filename(out_dir: &Path, target: &str, basename: &str) -> PathBuf {
    if target.contains("windows-msvc") {
        out_dir.join(format!("{basename}.lib"))
    } else {
        out_dir.join(format!("lib{basename}.a"))
    }
}

fn run(program: &str, args: &[&str]) {
    let status = Command::new(program)
        .args(args)
        .status()
        .unwrap_or_else(|e| panic!("failed to run {program}: {e}"));
    if !status.success() {
        panic!("{program} failed with status {status}");
    }
}

fn run_cmd(mut cmd: Command) {
    let status = cmd
        .status()
        .unwrap_or_else(|e| panic!("failed to run command: {e}"));
    if !status.success() {
        panic!("command failed with status {status}");
    }
}
