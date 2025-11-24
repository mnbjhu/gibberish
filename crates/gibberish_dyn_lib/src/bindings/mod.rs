// mod ext;
mod state;

use gibberish_tree::{
    lang::CompiledLang,
    node::{Lexeme, LexemeData, Node},
    vec::RawVec,
};
use libloading::Symbol;

use crate::bindings::state::{State, StateData};

// pub fn default_state_ptr(ptr: *const u8, len: usize) -> *const StateData;
// pub fn parse(ptr: *const StateData) -> u32;
//
pub fn lex(lang: &CompiledLang, text: &str) -> Vec<LexemeData> {
    unsafe {
        let lex: Symbol<unsafe extern "C" fn(*const u8, usize) -> RawVec<LexemeData>> =
            lang.0.get(b"lex").unwrap();

        // Call it
        let res = lex(text.as_ptr(), text.len());
        Vec::from(res)
    }
}

pub fn parse(lang: &CompiledLang, text: &str) -> Node<CompiledLang> {
    unsafe {
        let default_state_ptr: Symbol<unsafe extern "C" fn(*const u8, usize) -> *const StateData> =
            lang.0.get(b"default_state_ptr").unwrap();

        let get_state: Symbol<unsafe extern "C" fn(*const StateData) -> StateData> =
            lang.0.get(b"get_state").unwrap();

        let parse: Symbol<unsafe extern "C" fn(*const StateData) -> u32> =
            lang.0.get(b"parse").unwrap();

        // Call it
        let ptr = default_state_ptr(text.as_ptr(), text.len());
        parse(ptr);
        let state = get_state(ptr);
        State::from_data(state, text).stack.pop().unwrap()
    }
}

#[cfg(test)]
mod tests {
    use std::mem;

    use gibberish_tree::lang::CompiledLang;
    use libloading::Symbol;

    use crate::bindings::state::{State, StateData};

    #[test]
    fn test_free() {
        let lang = CompiledLang::load("../gibberish_bindings/libqbeslice.so");
        let text = "keyword test";
        unsafe {
            let default_state_ptr: Symbol<
                unsafe extern "C" fn(*const u8, usize) -> *const StateData,
            > = lang.0.get(b"default_state_ptr").unwrap();

            let get_state: Symbol<unsafe extern "C" fn(*const StateData) -> StateData> =
                lang.0.get(b"get_state").unwrap();

            let parse: Symbol<unsafe extern "C" fn(*const StateData) -> u32> =
                lang.0.get(b"parse").unwrap();

            // Call it
            let ptr = default_state_ptr(text.as_ptr(), text.len());
            parse(ptr);
            let free_state: Symbol<unsafe extern "C" fn(*const StateData) -> ()> =
                lang.0.get(b"free_state").unwrap();
            let state = get_state(ptr);
            State::from_data(state, text);
            free_state(ptr);
        }
    }
}
