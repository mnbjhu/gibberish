use std::fmt::{Debug, Display};
use std::hash::Hash;

use libloading::{AsFilename, Library, Symbol};

pub trait Lang: PartialEq + Eq + Display + Debug + Hash + Clone {
    type Token: Clone + PartialEq + Eq + Display + Debug + Hash;
    type Syntax: Clone + PartialEq + Eq + Display + Debug + Hash;

    fn token_name(&self, token: &Self::Token) -> String {
        format!("{token}")
    }
    fn syntax_name(&self, syntax: &Self::Syntax) -> String {
        format!("{syntax}")
    }
}

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

    fn token_name(&self, token: &Self::Token) -> String {
        unsafe {
            let tok: Symbol<unsafe extern "C" fn(u32) -> (*const u8, usize)> =
                self.0.get(b"token_name").unwrap();
            let (ptr, len) = tok(*token);
            let bytes = std::slice::from_raw_parts(ptr, len);
            str::from_utf8_unchecked(bytes).to_string()
        }
    }

    fn syntax_name(&self, syntax: &Self::Syntax) -> String {
        unsafe {
            let syn: Symbol<unsafe extern "C" fn(u32) -> (*const u8, usize)> =
                self.0.get(b"group_name").unwrap();
            let (ptr, len) = syn(*syntax);
            let bytes = std::slice::from_raw_parts(ptr, len);
            str::from_utf8_unchecked(bytes).to_string()
        }
    }
}
