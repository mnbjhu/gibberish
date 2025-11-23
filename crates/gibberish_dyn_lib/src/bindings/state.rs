use std::mem::{self, ManuallyDrop};

use gibberish_tree::{
    lang::CompiledLang,
    node::{Lexeme, Node, NodeData},
};
use libloading::Symbol;

use crate::bindings::vec::RawVec;

#[derive(Debug)]
pub struct State {
    pub tokens: Vec<Lexeme<CompiledLang>>,
    pub stack: Vec<Node<CompiledLang>>,
    pub offset: usize,
    pub delim_stack: Vec<usize>,
    pub skip: Vec<usize>,
}

#[repr(C)]
#[derive(Debug, Clone)]
pub struct StateData {
    pub tokens: RawVec<Lexeme<CompiledLang>>,
    stack: RawVec<NodeData>,
    offset: usize,
    delim_stack: RawVec<usize>,
    skip: RawVec<usize>,
}

impl State {
    pub fn from_data(value: &StateData, src: &str) -> Self {
        let tokens = value.tokens.clone().into();
        println!("Converted tokens");
        let stack = Vec::from(value.stack.clone())
            .into_iter()
            .map(|it| Node::from_data(it, src, &mut 0))
            .collect();
        println!("Converted stack");
        let delim_stack = value.delim_stack.clone().into();
        println!("Converted delim_stack");
        let skip = value.skip.clone().into();
        println!("Converted skip");
        Self {
            tokens,
            stack,
            offset: value.offset,
            delim_stack,
            skip,
        }
    }
}

impl State {
    pub fn from(value: &str, lang: CompiledLang) -> Self {
        unsafe {
            // Load a symbol (function)
            let func: Symbol<unsafe extern "C" fn(*const u8, usize) -> StateData> =
                lang.0.get(b"default_state").unwrap();

            // Call it
            let result = func(value.as_ptr(), value.len());
            State::from_data(&result, value)
        }
    }
}
