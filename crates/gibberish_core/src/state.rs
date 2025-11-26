use crate::{
    lang::CompiledLang,
    node::{Lexeme, LexemeData, Node, NodeData},
    vec::RawVec,
};
use libloading::Symbol;

#[derive(Debug)]
pub struct State {
    pub tokens: Vec<Lexeme<CompiledLang>>,
    pub stack: Vec<Node<CompiledLang>>,
    pub offset: usize,
    pub delim_stack: Vec<usize>,
    pub skip: Vec<usize>,
}

#[derive(Clone)]
#[repr(C)]
pub struct StateData {
    pub tokens: RawVec<LexemeData>,
    stack: RawVec<NodeData>,
    offset: usize,
    delim_stack: RawVec<usize>,
    skip: RawVec<usize>,
}

impl State {
    pub fn from_data(value: StateData, src: &str) -> Self {
        let tokens = Vec::from(value.tokens)
            .into_iter()
            .map(|it| Lexeme::from_data(it, src))
            .collect();
        let stack = Vec::from(value.stack)
            .into_iter()
            .map(|it| Node::from_data(it, src, &mut 0))
            .collect();
        let delim_stack = value.delim_stack.into();
        let skip = value.skip.into();
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
            let default_state: Symbol<unsafe extern "C" fn(*const u8, usize) -> StateData> =
                lang.0.get(b"default_state").unwrap();
            let result = default_state(value.as_ptr(), value.len());
            State::from_data(result, value)
        }
    }
}
