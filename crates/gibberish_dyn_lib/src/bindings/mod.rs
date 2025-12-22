use std::mem;

use gibberish_core::{
    node::{LexemeData, Node, NodeData},
    vec::RawVec,
};
use libloading::Symbol;

use crate::bindings::lang::CompiledLang;

pub mod lang;

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
        let p: Symbol<unsafe extern "C" fn(*const u8, usize) -> NodeData> =
            lang.0.get(b"parse").unwrap();

        mem::transmute(Node::from_data(p(text.as_ptr(), text.len()), text, &mut 0))
    }
}
