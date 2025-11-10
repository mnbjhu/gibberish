use crate::{
    expected::{Expected, ExpectedData},
    lex::Lexeme,
    vec::SliceData,
};

#[link(name = "qbeslice", kind = "static")]
unsafe extern "C" {
    pub fn token_name(id: u32) -> SliceData;
    pub fn group_name(id: u32) -> SliceData;
}

#[derive(Debug)]
pub enum Node {
    Group { kind: u32, children: Vec<Node> },
    Token { kind: u32 },
    Error { tokens: Vec<Lexeme> },
    Missing { expected: Vec<Expected> },
    Debug { kind: u32, a: u64, b: u64, c: u64 },
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
                    value.a as *mut ExpectedData,
                    value.b as usize,
                    value.c as usize,
                );
                Node::Missing {
                    expected: expected.into_iter().map(|it| it.into()).collect(),
                }
            },
            id => Node::Debug {
                kind: id,
                a: value.a,
                b: value.b,
                c: value.c,
            },
        }
    }
}

impl Node {
    pub fn debug(&self, text: &str) {
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
                    println!(
                        "MISSING: Expected: {}",
                        expected
                            .iter()
                            .map(|it| it.to_string())
                            .collect::<Vec<_>>()
                            .join(", ")
                    );
                }
                Node::Debug { .. } => println!("$DEBUG$"),
            }
        }
    }
}
