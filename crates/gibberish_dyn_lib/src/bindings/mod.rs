use std::{mem::ManuallyDrop, path::Path};

mod state;
mod vec;

use gibberish_tree::{lang::CompiledLang, node::Node};
use libloading::{Library, Symbol};

use crate::bindings::state::{State, StateData};

// pub fn default_state_ptr(ptr: *const u8, len: usize) -> *const StateData;
// pub fn parse(ptr: *const StateData) -> u32;
//

pub struct ParseResult<'a> {
    pub root: ManuallyDrop<Node<CompiledLang>>,
    lang: &'a CompiledLang,
    state_ptr: *const StateData,
}

impl<'a> Drop for ParseResult<'a> {
    fn drop(&mut self) {
        let free_state: Symbol<unsafe extern "C" fn(*const StateData) -> ()> =
            unsafe { self.lang.0.get(b"free_state") }.unwrap();
        unsafe { free_state(self.state_ptr) }
    }
}

pub fn parse<'a>(lang: &'a CompiledLang, text: &str) -> Node<CompiledLang> {
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
        State::from_data(ptr.as_ref().unwrap(), text)
            .stack
            .pop()
            .unwrap()
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
            State::from_data(&*ptr, text);
            free_state(ptr);
        }
    }
}
