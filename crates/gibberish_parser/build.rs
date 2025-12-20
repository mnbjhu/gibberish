// build.rs
//
// Builds a static library from a C source at lib/parser.c and links it into this crate.
// Assumes a C toolchain is available on PATH.
//
// Platform behavior:
// - Unix (linux/macos): uses `cc` + `ar` to create `lib<basename>.a`
// - Windows MSVC: uses `cl.exe` + `lib.exe` to create `<basename>.lib`
// - Windows GNU (MinGW): uses `cc` + `ar` (or `llvm-ar`) to create `lib<basename>.a`
//
// Notes:
// - Do NOT use the Windows `LIB` env var as a program name; it is a search-path variable.
// - On Windows GNU, `ar` may not be on PATH unless MinGW/MSYS2 is installed; `llvm-ar` may exist instead.

use std::{
    env,
    path::{Path, PathBuf},
    process::{Command, Stdio},
};

fn main() {
    // ---- inputs ----
    let c_src = Path::new("lib/parser.c");
    println!("cargo:rerun-if-changed={}", c_src.display());

    let c_hdr = Path::new("lib/parser.h");
    if c_hdr.exists() {
        println!("cargo:rerun-if-changed={}", c_hdr.display());
    }

    // ---- environment ----
    let target = env::var("TARGET").expect("TARGET not set");
    let target_env = env::var("CARGO_CFG_TARGET_ENV").unwrap_or_default(); // "gnu" | "msvc" | ...
    let target_os = env::var("CARGO_CFG_TARGET_OS").unwrap_or_default(); // "windows" | "linux" | "macos" | ...
    let out_dir = PathBuf::from(env::var("OUT_DIR").expect("OUT_DIR not set"));

    // Parameterized static library basename (no "lib" prefix, no extension)
    let lib_basename: &str = "gibberish-parser";

    // ---- derived paths ----
    let is_windows = target_os == "windows" || target.contains("windows");
    let is_msvc = target_env == "msvc" || target.contains("windows-msvc");

    let obj_path = if is_msvc {
        out_dir.join("parser.obj")
    } else {
        // GCC/Clang on Unix and Windows GNU produce .o
        out_dir.join("parser.o")
    };

    let lib_path = static_lib_path(&out_dir, is_msvc, lib_basename);

    // ---- 1) Compile: C -> object ----
    if is_msvc {
        compile_c_msvc(c_src, &obj_path);
    } else {
        compile_c_cc(c_src, &obj_path, /*pic*/ !is_windows);
    }

    // ---- 2) Archive: object -> static library ----
    if is_msvc {
        archive_msvc(&obj_path, &lib_path);
    } else {
        archive_ar(&obj_path, &lib_path);
    }

    // ---- 3) Tell Cargo/rustc how to link it ----
    println!("cargo:rustc-link-search=native={}", out_dir.display());
    println!("cargo:rustc-link-lib=static={}", lib_basename);

    // Helpful diagnostics when something goes wrong on CI.
    println!("cargo:warning=build.rs target={target}");
    println!("cargo:warning=build.rs target_env={target_env}");
    println!("cargo:warning=build.rs target_os={target_os}");
    println!("cargo:warning=build.rs obj={}", obj_path.display());
    println!("cargo:warning=build.rs lib={}", lib_path.display());
}

fn static_lib_path(out_dir: &Path, is_msvc: bool, basename: &str) -> PathBuf {
    if is_msvc {
        out_dir.join(format!("{basename}.lib"))
    } else {
        out_dir.join(format!("lib{basename}.a"))
    }
}

fn compile_c_cc(c_src: &Path, obj_path: &Path, pic: bool) {
    let cc = env::var("CC").unwrap_or_else(|_| "cc".to_string());

    let mut cmd = Command::new(cc);
    cmd.arg("-c")
        .arg(c_src)
        .arg("-o")
        .arg(obj_path)
        // If your C file includes headers from lib/, add include path:
        .arg("-I")
        .arg("lib")
        // Debug-ish flags (keep if you want):
        .arg("-g")
        .arg("-fno-omit-frame-pointer");

    // PIC is relevant on Unix; on Windows GNU it’s usually unnecessary.
    if pic {
        cmd.arg("-fPIC");
    }

    // If you want C standard selection:
    // cmd.arg("-std=c11");

    run_cmd(&mut cmd);
}

fn compile_c_msvc(c_src: &Path, obj_path: &Path) {
    // Use cl.exe when building with MSVC. This assumes the MSVC developer tools are on PATH.
    // If not, consider using the `cc` crate which handles MSVC tool discovery.
    let cl = env::var("CL").unwrap_or_else(|_| "cl.exe".to_string());

    // cl.exe requires `/Fo<path>` (no space) to set object output.
    let fo = format!("/Fo{}", obj_path.to_string_lossy());

    let mut cmd = Command::new(cl);
    cmd.arg("/nologo")
        .arg("/c")
        // include path
        .arg("/Ilib")
        // debug-ish flags comparable to -g (optional)
        .arg("/Zi")
        .arg("/Od")
        .arg(fo)
        .arg(c_src);

    run_cmd(&mut cmd);
}

fn archive_ar(obj_path: &Path, lib_path: &Path) {
    // Prefer explicit AR override; else try a few common candidates.
    let ar = pick_tool(&["AR"], &["ar", "llvm-ar", "gcc-ar"])
        .unwrap_or_else(|| {
            panic!(
                "No archiver found. Install MinGW/MSYS2 (providing `ar`) or LLVM (providing `llvm-ar`), \
or set AR=/path/to/ar."
            )
        });

    let mut cmd = Command::new(ar);
    cmd.args([
        "rcs",
        lib_path.to_str().unwrap(),
        obj_path.to_str().unwrap(),
    ]);
    run_cmd(&mut cmd);
}

fn archive_msvc(obj_path: &Path, lib_path: &Path) {
    // IMPORTANT: Do NOT use the `LIB` env var. It is a search-path, not the tool.
    // Allow override via LIB_EXE; default to lib.exe.
    let libexe = env::var("LIB_EXE").unwrap_or_else(|_| "lib.exe".to_string());
    let out_flag = format!("/OUT:{}", lib_path.to_string_lossy());

    let mut cmd = Command::new(libexe);
    cmd.arg("/nologo").arg(out_flag).arg(obj_path);
    run_cmd(&mut cmd);
}

fn pick_tool(env_vars: &[&str], candidates: &[&str]) -> Option<String> {
    for &var in env_vars {
        if let Ok(v) = env::var(var) {
            if !v.trim().is_empty() {
                return Some(v);
            }
        }
    }

    for &c in candidates {
        if tool_exists(c) {
            return Some(c.to_string());
        }
    }

    None
}

fn tool_exists(name: &str) -> bool {
    Command::new(name)
        .arg("--version")
        .stdin(Stdio::null())
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .is_ok()
}

fn run_cmd(cmd: &mut Command) {
    eprintln!("Running: {:?}", cmd);

    let status = cmd
        .status()
        .unwrap_or_else(|e| panic!("failed to run {:?}: {e}", cmd));

    if !status.success() {
        panic!("command {:?} failed with status {status}", cmd);
    }
}
