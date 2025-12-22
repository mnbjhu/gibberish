use std::{ffi::CStr, fmt::Display};

use gibberish_core::lang::Lang;
use libloading::{AsFilename, Library, Symbol};
use safer_ffi::libc::c_char;

#[derive(Debug)]
pub struct CompiledLang(pub Library);

impl CompiledLang {
    pub fn load(path: impl AsFilename) -> Self {
        CompiledLang(unsafe { Library::new(path).unwrap() })
    }
}

impl PartialEq for CompiledLang {
    fn eq(&self, _: &Self) -> bool {
        todo!()
    }
}

impl Eq for CompiledLang {}

impl Clone for CompiledLang {
    fn clone(&self) -> Self {
        todo!()
    }
}

impl std::hash::Hash for CompiledLang {
    fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
        std::ptr::hash(self, state);
    }
}

impl Display for CompiledLang {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "CompiledLang")
    }
}

impl Lang for CompiledLang {
    type Token = u32;
    type Syntax = u32;
    type Label = u32;

    fn token_name(&self, token: &Self::Token) -> String {
        unsafe {
            let tok: Symbol<unsafe extern "C" fn(u32) -> *const c_char> =
                self.0.get(b"token_name").unwrap();
            CStr::from_ptr(tok(*token)).to_str().unwrap().to_string()
        }
    }

    fn syntax_name(&self, syntax: &Self::Syntax) -> String {
        unsafe {
            let syn: Symbol<unsafe extern "C" fn(u32) -> *const c_char> =
                self.0.get(b"group_name").unwrap();
            CStr::from_ptr(syn(*syntax)).to_str().unwrap().to_string()
        }
    }

    fn label_name(&self, syntax: &Self::Label) -> String {
        unsafe {
            let syn: Symbol<unsafe extern "C" fn(u32) -> (*const u8, usize)> =
                self.0.get(b"label_name").unwrap();
            let (ptr, len) = syn(*syntax);
            let bytes = std::slice::from_raw_parts(ptr, len);
            str::from_utf8_unchecked(bytes).to_string()
        }
    }
}
