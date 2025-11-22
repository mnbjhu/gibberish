use std::path::Path;

mod state;
mod vec;

use gibberish_tree::{lang::CompiledLang, node::Node};
use libloading::{Library, Symbol};

use crate::bindings::state::{State, StateData};

// pub fn default_state_ptr(ptr: *const u8, len: usize) -> *const StateData;
// pub fn parse(ptr: *const StateData) -> u32;

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
        let state_data = get_state(ptr);
        // for item in &state_data.tokens {
        //     println!(
        //         "kind: {}, start: {}, end: {}",
        //         item.kind, item.span.start, item.span.end
        //     );
        // }
        println!("{state_data:?}");
        State::from_data(state_data, text).stack.pop().unwrap()
    }
}
