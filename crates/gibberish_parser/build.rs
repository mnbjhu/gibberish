// build.rs
//
// Builds a static library from lib/parser.c and links it into this crate.
//
// Platform behavior:
// - target_env=msvc: cl.exe + lib.exe => <basename>.lib
// - otherwise (gnu/unix): cc + ar/llvm-ar => lib<basename>.a
//
// Robustness:
// - Uses absolute paths via CARGO_MANIFEST_DIR (fixes Windows cwd quirks)
// - Detects MSVC only via CARGO_CFG_TARGET_ENV (prevents cl.exe on windows-gnu)

use std::{
    env,
    path::{Path, PathBuf},
    process::{Command, Stdio},
};

fn main() {
    let manifest_dir =
        PathBuf::from(env::var("CARGO_MANIFEST_DIR").expect("CARGO_MANIFEST_DIR not set"));
    let out_dir = PathBuf::from(env::var("OUT_DIR").expect("OUT_DIR not set"));

    // Inputs (absolute)
    let c_src = manifest_dir.join("lib").join("parser.c");
    let include_dir = manifest_dir.join("lib");

    println!("cargo:rerun-if-changed={}", c_src.display());
    let c_hdr = manifest_dir.join("lib").join("parser.h");
    if c_hdr.exists() {
        println!("cargo:rerun-if-changed={}", c_hdr.display());
    }

    if !c_src.exists() {
        panic!("C source not found at {}", c_src.display());
    }

    // Target info (from Cargo for the *target*, not host)
    let target = env::var("TARGET").expect("TARGET not set");
    let target_os = env::var("CARGO_CFG_TARGET_OS").unwrap_or_else(|_| "<unknown>".into());
    let target_env = env::var("CARGO_CFG_TARGET_ENV").unwrap_or_else(|_| "<unknown>".into());

    // IMPORTANT: only this decides MSVC vs GNU
    let is_msvc = target_env == "msvc";
    let is_windows = target_os == "windows";

    // Debug output so CI logs show what branch we took
    println!(
        "cargo:warning=build.rs cwd={}",
        env::current_dir().unwrap().display()
    );
    println!("cargo:warning=build.rs TARGET={}", target);
    println!("cargo:warning=build.rs CARGO_CFG_TARGET_OS={}", target_os);
    println!("cargo:warning=build.rs CARGO_CFG_TARGET_ENV={}", target_env);
    println!("cargo:warning=build.rs is_msvc={}", is_msvc);
    println!("cargo:warning=build.rs c_src={}", c_src.display());

    // Library naming
    let lib_basename: &str = "gibberish-parser";

    // Outputs
    let obj_path = if is_msvc {
        out_dir.join("parser.obj")
    } else {
        out_dir.join("parser.o")
    };

    let lib_path = if is_msvc {
        out_dir.join(format!("{lib_basename}.lib"))
    } else {
        out_dir.join(format!("lib{lib_basename}.a"))
    };

    // 1) Compile: C -> object
    if is_msvc {
        compile_c_msvc(&c_src, &obj_path, &include_dir);
    } else {
        // PIC matters on Unix; on Windows GNU it’s unnecessary (and sometimes unsupported).
        let pic = !is_windows;
        compile_c_cc(&c_src, &obj_path, &include_dir, pic);
    }

    // 2) Archive: object -> static lib
    if is_msvc {
        archive_msvc(&obj_path, &lib_path);
    } else {
        archive_gnu(&obj_path, &lib_path);
    }

    // 3) Tell Cargo/rustc how to link it
    println!("cargo:rustc-link-search=native={}", out_dir.display());
    println!("cargo:rustc-link-lib=static={}", lib_basename);
}

fn compile_c_cc(c_src: &Path, obj_path: &Path, include_dir: &Path, pic: bool) {
    let cc = env::var("CC").unwrap_or_else(|_| "cc".to_string());

    let mut cmd = Command::new(cc);
    cmd.arg("-c")
        .arg(c_src)
        .arg("-o")
        .arg(obj_path)
        .arg("-I")
        .arg(include_dir)
        .arg("-g")
        .arg("-fno-omit-frame-pointer");

    if pic {
        cmd.arg("-fPIC");
    }

    run_cmd(&mut cmd);
}

fn compile_c_msvc(c_src: &Path, obj_path: &Path, include_dir: &Path) {
    let cl = env::var("CL_EXE").unwrap_or_else(|_| "cl.exe".to_string());

    let fo = format!("/Fo{}", obj_path.to_string_lossy()); // no space
    let inc = format!("/I{}", include_dir.to_string_lossy());

    let mut cmd = Command::new(cl);
    cmd.arg("/nologo")
        .arg("/c")
        .arg(inc)
        .arg("/Zi")
        .arg("/Od")
        .arg(fo)
        .arg(c_src);

    run_cmd(&mut cmd);
}

fn archive_gnu(obj_path: &Path, lib_path: &Path) {
    let ar = env::var("AR")
        .ok()
        .filter(|s| !s.trim().is_empty())
        .or_else(|| find_tool(&["ar", "llvm-ar", "gcc-ar"]))
        .unwrap_or_else(|| {
            panic!(
                "No archiver found. On windows-gnu you need MinGW/MSYS2 (ar.exe) or LLVM (llvm-ar). \
You can also set AR=llvm-ar."
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
    // Do not use `LIB` env var (search path). Use lib.exe (or override with LIB_EXE).
    let libexe = env::var("LIB_EXE").unwrap_or_else(|_| "lib.exe".to_string());
    let out_flag = format!("/OUT:{}", lib_path.to_string_lossy());

    let mut cmd = Command::new(libexe);
    cmd.arg("/nologo").arg(out_flag).arg(obj_path);
    run_cmd(&mut cmd);
}

fn find_tool(candidates: &[&str]) -> Option<String> {
    for &c in candidates {
        if Command::new(c)
            .arg("--version")
            .stdin(Stdio::null())
            .stdout(Stdio::null())
            .stderr(Stdio::null())
            .status()
            .is_ok()
        {
            return Some(c.to_string());
        }
    }
    None
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
