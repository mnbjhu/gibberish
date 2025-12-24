use std::path::{Path, PathBuf};
use std::process::Command;

pub fn build_shared_c_library(c_file: &Path, out: &Path) {
    init_cc_env();
    let out_dir = out.parent().unwrap();
    let mut b = cc::Build::new();
    b.cargo_metadata(false);
    b.out_dir(out_dir);
    if b.get_compiler().is_like_msvc() {
        b.flag("/w");
    } else {
        b.flag("-w");
    }
    if !cfg!(windows) {
        b.pic(true);
    }
    let tool = b.try_get_compiler().unwrap();
    let obj_ext = if tool.is_like_msvc() { "obj" } else { "o" };
    let without_ext = PathBuf::from(out_dir.file_stem().unwrap());
    let mut obj_path = without_ext.clone();
    obj_path.set_extension(obj_ext);
    let mut compile_cmd: Command = tool.to_command();
    if tool.is_like_msvc() {
        compile_cmd.args([
            "/nologo",
            "/c",
            c_file.as_os_str().to_str().unwrap(),
            &format!("/Fo{}", obj_path.display()),
        ]);
    } else {
        compile_cmd.args([
            "-c",
            c_file.as_os_str().to_str().unwrap(),
            "-o",
            obj_path.as_os_str().to_str().unwrap(),
        ]);
    }

    run_ok(&mut compile_cmd, "compile").unwrap();

    let mut link_cmd: Command = tool.to_command();
    if tool.is_like_msvc() {
        link_cmd.args([
            "/nologo",
            "/LD",
            obj_path.as_os_str().to_str().unwrap(),
            "/link",
            &format!("/OUT:{}", out.display()),
        ]);
    } else if cfg!(target_os = "macos") {
        link_cmd.args([
            "-dynamiclib",
            obj_path.as_os_str().to_str().unwrap(),
            "-o",
            out.as_os_str().to_str().unwrap(),
        ]);
    } else {
        link_cmd.args([
            "-shared",
            obj_path.as_os_str().to_str().unwrap(),
            "-o",
            out.as_os_str().to_str().unwrap(),
        ]);
        if cfg!(windows) {
            let name = without_ext.file_name().unwrap().to_str().unwrap();
            let implib = out_dir.join(format!("lib{name}.dll.a"));
            link_cmd.arg(format!("-Wl,--out-implib,{}", implib.display()));
        }
    }

    run_ok(&mut link_cmd, "link").unwrap();
}

fn run_ok(cmd: &mut Command, phase: &str) -> Result<(), Box<dyn std::error::Error>> {
    let status = cmd.status()?;
    if !status.success() {
        return Err(format!("{phase} failed with status: {status}").into());
    }
    Ok(())
}

fn init_cc_env() {
    use std::env::{set_var, var};
    unsafe {
        // Pretend we're a Cargo build script
        if var("HOST").is_err() {
            let host = format!("{}-{}", std::env::consts::ARCH, std::env::consts::OS);
            set_var("HOST", &host);
        }

        if var("TARGET").is_err() {
            set_var("TARGET", var("HOST").unwrap());
        }

        if var("OPT_LEVEL").is_err() {
            set_var("OPT_LEVEL", "2"); // sensible default
        }

        if var("DEBUG").is_err() {
            set_var("DEBUG", "0");
        }

        if var("PROFILE").is_err() {
            set_var("PROFILE", "release");
        }

        if var("CARGO_CFG_TARGET_OS").is_err() {
            set_var("CARGO_CFG_TARGET_OS", std::env::consts::OS);
        }

        if var("CARGO_CFG_TARGET_ENV").is_err() {
            // Windows distinction that cc cares about
            if cfg!(windows) {
                if cfg!(target_env = "msvc") {
                    set_var("CARGO_CFG_TARGET_ENV", "msvc");
                } else {
                    set_var("CARGO_CFG_TARGET_ENV", "gnu");
                }
            } else {
                set_var("CARGO_CFG_TARGET_ENV", "");
            }
        }
    }
}

pub fn build_static_c_library(c_file: &Path, out: &Path) {
    init_cc_env();
    let out_dir = out.parent().unwrap();
    let mut b = cc::Build::new();
    b.cargo_metadata(false);
    b.out_dir(out_dir);
    if b.get_compiler().is_like_msvc() {
        b.flag("/w");
    } else {
        b.flag("-w");
    }
    if !cfg!(windows) {
        b.pic(true);
    }
    let tool = b.try_get_compiler().unwrap();
    let obj_ext = if tool.is_like_msvc() { "obj" } else { "o" };
    let mut obj_path = out.to_path_buf();
    obj_path.set_extension(obj_ext);

    let mut compile_cmd: Command = tool.to_command();
    if tool.is_like_msvc() {
        compile_cmd.args([
            "/nologo",
            "/c",
            c_file.as_os_str().to_str().unwrap(),
            &format!("/Fo{}", obj_path.display()),
        ]);
    } else {
        compile_cmd.args([
            "-c",
            c_file.as_os_str().to_str().unwrap(),
            "-o",
            obj_path.as_os_str().to_str().unwrap(),
        ]);
    }

    run_ok(&mut compile_cmd, "compile").unwrap();

    if tool.is_like_msvc() {
        let lib_exe = find_msvc_lib_exe().unwrap_or_else(|| PathBuf::from("lib"));

        let mut ar_cmd = Command::new(lib_exe);
        ar_cmd.args([
            "/nologo",
            &format!("/OUT:{}", out.display()),
            obj_path.as_os_str().to_str().unwrap(),
        ]);

        run_ok(&mut ar_cmd, "archive").unwrap();
    } else {
        let ar = std::env::var_os("AR").unwrap_or_else(|| "ar".into());

        let mut ar_cmd = Command::new(ar);
        ar_cmd.args([
            "crs",
            out.as_os_str().to_str().unwrap(),
            obj_path.as_os_str().to_str().unwrap(),
        ]);

        run_ok(&mut ar_cmd, "archive").unwrap();
        if let Some(ranlib) = std::env::var_os("RANLIB") {
            let mut ranlib_cmd = Command::new(ranlib);
            ranlib_cmd.arg(out.as_os_str().to_str().unwrap());
            let _ = run_ok(&mut ranlib_cmd, "ranlib");
        }
    }
}

fn find_msvc_lib_exe() -> Option<PathBuf> {
    if let Ok(vctools) = std::env::var("VCToolsInstallDir") {
        let candidates = [
            ["bin", "Hostx64", "x64", "lib.exe"],
            ["bin", "Hostx64", "x86", "lib.exe"],
            ["bin", "Hostx86", "x86", "lib.exe"],
            ["bin", "Hostx86", "x64", "lib.exe"],
        ];

        for parts in candidates {
            let p = parts
                .iter()
                .fold(PathBuf::from(&vctools), |acc, s| acc.join(s));
            if p.exists() {
                return Some(p);
            }
        }
    }

    if let Ok(vc) = std::env::var("VCINSTALLDIR") {
        let p = PathBuf::from(vc).join("bin").join("lib.exe");
        if p.exists() {
            return Some(p);
        }
    }

    None
}
