use std::fmt::Write;

#[link(name = "qbeslice", kind = "static")]
unsafe extern "C" {
    // 0 = WS, 1 = INT, 2 = STRING, 3 = ERROR
    fn test_node() -> NodeData;
    fn test_state(ptr: *const u8, len: usize) -> StateData;
    fn default_state(ptr: *const u8, len: usize) -> StateData;
    fn default_state_ptr(ptr: *const u8, len: usize) -> *const StateData;
    fn new_vec(size: u32) -> LexemeVec;
    fn name(id: u32) -> SliceData;
    fn lex(ptr: *const u8, len: usize) -> LexemeVec;
    fn bump(ptr: *const StateData);
    fn bumpN(ptr: *const StateData, n: usize) -> u32;
    fn enter_group(ptr: *const StateData, name: u32) -> u32;
    fn exit_group(ptr: *const StateData) -> u32;
    fn get_state(ptr: *const StateData) -> StateData;
}

#[repr(C)]
pub struct SliceData {
    ptr: *const u8,
    len: usize,
}

pub fn do_test() -> Node {
    unsafe { test_node().into() }
}

pub fn do_new_vec() -> Vec<Lexeme> {
    unsafe {
        let slice = new_vec(24);
        Vec::from_raw_parts(slice.ptr, slice.len as usize, slice.cap as usize)
    }
}

#[repr(C)]
#[derive(Debug)]
pub struct NodeData {
    kind: u32,
    group_kind: u32,
    a: u64,
    b: u64,
    c: u64,
}
impl From<StateData> for State {
    fn from(value: StateData) -> Self {
        unsafe {
            let tokens = Vec::from_raw_parts(value.tokens_ptr, value.tokens_len, value.tokens_cap);
            let stack = Vec::from_raw_parts(value.stack_ptr, value.stack_len, value.stack_cap)
                .into_iter()
                .map(Node::from)
                .collect();
            Self {
                tokens,
                stack,
                offset: value.offset,
            }
        }
    }
}

impl From<NodeData> for Node {
    fn from(value: NodeData) -> Self {
        match value.kind {
            0 => Node::Token {
                kind: value.a as u32,
            },
            1 => unsafe {
                let children = Vec::from_raw_parts(
                    value.a as *mut NodeData,
                    value.b as usize,
                    value.c as usize,
                );
                Node::Group {
                    kind: value.group_kind,
                    children: children.into_iter().map(|it| it.into()).collect(),
                }
            },
            id => panic!("Unexpected Node kind {id}"),
        }
    }
}

#[derive(Debug)]
pub enum Node {
    Group { kind: u32, children: Vec<Node> },
    Token { kind: u32 },
}

#[repr(C)]
#[derive(Debug)]
pub struct LexemeVec {
    ptr: *mut Lexeme,
    len: usize,
    cap: usize,
}

#[repr(C)]
#[derive(Debug)]
pub struct NodeVec {
    ptr: *mut NodeData,
    len: u64,
    cap: u64,
}

#[repr(C)]
#[derive(Debug)]
pub struct Lexeme {
    kind: u64,
    start: u64,
    end: u64,
}

#[repr(C)]
#[derive(Debug)]
pub struct StateData {
    tokens_ptr: *mut Lexeme,
    tokens_len: usize,
    tokens_cap: usize,
    stack_ptr: *mut NodeData,
    stack_len: usize,
    stack_cap: usize,
    offset: usize,
}

#[derive(Debug)]
pub struct State {
    pub tokens: Vec<Lexeme>,
    pub stack: Vec<Node>,
    pub offset: usize,
}

impl From<SliceData> for &str {
    fn from(value: SliceData) -> Self {
        unsafe {
            let bytes = std::slice::from_raw_parts(value.ptr, value.len);
            str::from_utf8_unchecked(bytes)
        }
    }
}

impl From<LexemeVec> for Vec<Lexeme> {
    fn from(value: LexemeVec) -> Self {
        unsafe { Vec::from_raw_parts(value.ptr, value.len, value.cap) }
    }
}

fn do_lex(text: &str) -> Vec<Lexeme> {
    unsafe { lex(text.as_ptr(), text.len()).into() }
}

fn main() {
    // let res = State::test_state("select some from thing;");
    // println!("{res:#?}")
    unsafe {
        let text = "select some from thing;";
        let state_ptr = default_state_ptr(text.as_ptr(), text.len());
        bumpN(state_ptr, 3);
        enter_group(state_ptr, 42);
        bumpN(state_ptr, 2);
        exit_group(state_ptr);
        bumpN(state_ptr, 2);
        let state: State = get_state(state_ptr).into();
        println!("{state:#?}")
    }
}

impl From<&str> for State {
    fn from(value: &str) -> Self {
        unsafe { default_state(value.as_ptr(), value.len()).into() }
    }
}

impl State {
    fn test_state(value: &str) -> Self {
        unsafe { test_state(value.as_ptr(), value.len()).into() }
    }
}

impl Node {
    fn debug(&self, text: &str) {}
    fn debug_inner(&self, text: &str, offset: usize) {}
}
