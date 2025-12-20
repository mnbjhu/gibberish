use gibberish_core::{
    lang::CompiledLang,
    node::{LexemeData, Node, NodeData},
    state::{State, StateData},
    vec::RawVec,
};
use libloading::Symbol;

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

        Node::from_data(p(text.as_ptr(), text.len()), text, &mut 0)
    }
}
