use std::fmt::Display;

#[link(name = "qbeslice", kind = "static")]
unsafe extern "C" {
    // 0 = WS, 1 = INT, 2 = STRING, 3 = ERROR
    fn test_vec_contains() -> IntVec;
    fn default_state(ptr: *const u8, len: usize) -> StateData;
    fn default_state_ptr(ptr: *const u8, len: usize) -> *const StateData;
    fn new_vec(size: u32) -> LexemeVec;
    fn token_name(id: u32) -> SliceData;
    fn group_name(id: u32) -> SliceData;
    fn lex(ptr: *const u8, len: usize) -> LexemeVec;
    fn parse(ptr: *const StateData) -> u32;
    fn bump(ptr: *const StateData);
    fn bump_err(ptr: *const StateData);
    fn bumpN(ptr: *const StateData, n: usize) -> u32;
    fn enter_group(ptr: *const StateData, name: u32) -> u32;
    fn exit_group(ptr: *const StateData) -> u32;
    fn get_state(ptr: *const StateData) -> StateData;
    fn kind_at_offset(ptr: *const StateData, offset: usize) -> usize;
}

#[repr(C)]
pub struct SliceData {
    ptr: *const u8,
    len: usize,
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
            2 => unsafe {
                let tokens =
                    Vec::from_raw_parts(value.a as *mut Lexeme, value.b as usize, value.c as usize);
                Node::Error { tokens }
            },
            3 => unsafe {
                let expected = Vec::from_raw_parts(
                    value.a as *mut Expected,
                    value.b as usize,
                    value.c as usize,
                );
                Node::Missing { expected }
            },
            id => panic!("Unexpected Node kind {id}"),
        }
    }
}

#[repr(C)]
pub struct MyVec<T> {
    ptr: *mut T,
    len: usize,
    cap: usize,
}

#[derive(Debug)]
pub enum Expected {
    Token(u64),
    Group(u64),
    Label(u64),
}

impl Display for Expected {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let name: &str = unsafe {
            match self {
                Expected::Token(t) => token_name(*t as u32),
                Expected::Group(g) => group_name(*g as u32),
                Expected::Label(_) => todo!(),
            }
            .into()
        };
        write!(f, "{name}")
    }
}

#[derive(Debug)]
pub enum Node {
    Group { kind: u32, children: Vec<Node> },
    Token { kind: u32 },
    Error { tokens: Vec<Lexeme> },
    Missing { expected: Vec<Expected> },
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
pub struct IntVec {
    ptr: *mut u64,
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
    delim_stack_ptr: usize,
    delim_stack_len: usize,
    delim_stack_cap: usize,
    skip_ptr: usize,
    skip_len: usize,
    skip_cap: usize,
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
    unsafe {
        let text = "select 123";
        let state_ptr = default_state_ptr(text.as_ptr(), text.len());
        parse(state_ptr);
        let state: State = get_state(state_ptr).into();
        assert_eq!(state.stack.len(), 1);
        state.stack.first().unwrap().debug(text);
    }
}

impl From<&str> for State {
    fn from(value: &str) -> Self {
        unsafe { default_state(value.as_ptr(), value.len()).into() }
    }
}

impl Node {
    fn debug(&self, text: &str) {
        self.debug_inner(text, 0);
    }
    fn debug_inner(&self, text: &str, offset: usize) {
        for _ in 0..offset {
            print!("  ")
        }
        unsafe {
            match self {
                Node::Group { kind, children } => {
                    let name: &str = group_name(*kind).into();
                    println!("{name}");
                    for child in children {
                        child.debug_inner(text, offset + 1);
                    }
                }
                Node::Token { kind } => {
                    let name: &str = token_name(*kind).into();
                    println!("{name}")
                }
                Node::Error { tokens } => {
                    println!("ERROR");
                    for token in tokens {
                        for _ in 0..offset + 1 {
                            print!("  ")
                        }
                        let name: &str = token_name(token.kind as u32).into();
                        println!("{name}")
                    }
                }
                Node::Missing { expected } => {
                    println!("MISSING: Expected: {expected:?}");
                }
            }
        }
    }
}
