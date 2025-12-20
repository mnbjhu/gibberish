// build.rs
//
// Builds a static library from a C source at lib/parser.c and links it into this crate.
//
// Platform behavior:
// - Unix (linux/macos): uses `cc` + `ar` to create `lib<basename>.a`
// - Windows MSVC: uses `cl.exe` + `lib.exe` to create `<basename>.lib`
// - Windows GNU (MinGW): uses `cc` + `ar` (or `llvm-ar`) to create `lib<basename>.a`
//
// Key robustness details:
// - Uses absolute paths derived from CARGO_MANIFEST_DIR (fixes "lib/parser.c not found" on Windows).
// - Never uses the Windows `LIB` env var as a program name (it’s a search-path variable).
// - On Windows GNU, tries `ar`, `llvm-ar`, `gcc-ar` if AR isn’t set.

use std::{
    env,
    path::{Path, PathBuf},
    process::{Command, Stdio},
};

fn main() {
    // ---- stable base paths ----
    let manifest_dir =
        PathBuf::from(env::var("CARGO_MANIFEST_DIR").expect("CARGO_MANIFEST_DIR not set"));
    let out_dir = PathBuf::from(env::var("OUT_DIR").expect("OUT_DIR not set"));

    // ---- inputs (absolute paths) ----
    let c_src = manifest_dir.join("lib").join("parser.c");
    println!("cargo:rerun-if-changed={}", c_src.display());
    if !c_src.exists() {
        panic!("C source not found at {}", c_src.display());
    }

    let c_hdr = manifest_dir.join("lib").join("parser.h");
    if c_hdr.exists() {
        println!("cargo:rerun-if-changed={}", c_hdr.display());
    }

    // ---- target info ----
    let target = env::var("TARGET").expect("TARGET not set");
    let target_env = env::var("CARGO_CFG_TARGET_ENV").unwrap_or_default(); // "gnu" | "msvc" | ...
    let target_os = env::var("CARGO_CFG_TARGET_OS").unwrap_or_default(); // "windows" | "linux" | "macos" | ...

    let is_windows = target_os == "windows" || target.contains("windows");
    let is_msvc = target_env == "msvc" || target.contains("windows-msvc");

    // ---- configuration ----
    // Static library basename (no "lib" prefix, no extension)
    let lib_basename: &str = "gibberish-parser";

    // ---- derived outputs ----
    let obj_path = if is_msvc {
        out_dir.join("parser.obj")
    } else {
        out_dir.join("parser.o")
    };
    let lib_path = static_lib_path(&out_dir, is_msvc, lib_basename);

    // ---- diagnostics (useful on CI) ----
    println!(
        "cargo:warning=build.rs cwd={}",
        env::current_dir().unwrap().display()
    );
    println!(
        "cargo:warning=build.rs manifest_dir={}",
        manifest_dir.display()
    );
    println!("cargo:warning=build.rs out_dir={}", out_dir.display());
    println!("cargo:warning=build.rs target={target}");
    println!("cargo:warning=build.rs target_os={target_os}");
    println!("cargo:warning=build.rs target_env={target_env}");
    println!("cargo:warning=build.rs c_src={}", c_src.display());
    println!("cargo:warning=build.rs obj={}", obj_path.display());
    println!("cargo:warning=build.rs lib={}", lib_path.display());

    // ---- 1) Compile: C -> object ----
    if is_msvc {
        compile_c_msvc(&c_src, &obj_path, &manifest_dir.join("lib"));
    } else {
        // PIC matters on Unix; on Windows GNU it’s not needed.
        compile_c_cc(
            &c_src,
            &obj_path,
            &manifest_dir.join("lib"),
            /*pic*/ !is_windows,
        );
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
}

fn static_lib_path(out_dir: &Path, is_msvc: bool, basename: &str) -> PathBuf {
    if is_msvc {
        out_dir.join(format!("{basename}.lib"))
    } else {
        out_dir.join(format!("lib{basename}.a"))
    }
}

fn compile_c_cc(c_src: &Path, obj_path: &Path, include_dir: &Path, pic: bool) {
    let cc = env::var("CC").unwrap_or_else(|_| "cc".to_string());

    let mut cmd = Command::new(cc);
    cmd.arg("-c")
        .arg(c_src)
        .arg("-o")
        .arg(obj_path)
        // headers in lib/
        .arg("-I")
        .arg(include_dir)
        // debug-ish flags (optional)
        .arg("-g")
        .arg("-fno-omit-frame-pointer");

    if pic {
        cmd.arg("-fPIC");
    }

    // If you want a C standard:
    // cmd.arg("-std=c11");

    run_cmd(&mut cmd);
}

fn compile_c_msvc(c_src: &Path, obj_path: &Path, include_dir: &Path) {
    // CL can be overridden; otherwise default to cl.exe.
    // This assumes MSVC dev tools are available on PATH.
    let cl = env::var("CL_EXE").unwrap_or_else(|_| "cl.exe".to_string());

    // cl.exe expects /Fo<path> (no space)
    let fo = format!("/Fo{}", obj_path.to_string_lossy());
    let inc = format!("/I{}", include_dir.to_string_lossy());

    let mut cmd = Command::new(cl);
    cmd.arg("/nologo")
        .arg("/c")
        .arg(inc)
        // debug-ish flags (optional)
        .arg("/Zi")
        .arg("/Od")
        .arg(fo)
        .arg(c_src);

    run_cmd(&mut cmd);
}

fn archive_ar(obj_path: &Path, lib_path: &Path) {
    let ar = pick_tool(&["AR"], &["ar", "llvm-ar", "gcc-ar"]).unwrap_or_else(|| {
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
    // IMPORTANT: Do NOT use the `LIB` env var. It is a search path, not the tool.
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
            let v = v.trim();
            if !v.is_empty() {
                return Some(v.to_string());
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
