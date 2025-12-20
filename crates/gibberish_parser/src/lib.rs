
use std::{fmt::Display, mem};

use gibberish_core::{
    lang::Lang,
    node::{Lexeme, LexemeData, Node, NodeData},
    state::{State, StateData},
    vec::RawVec,
};

unsafe extern "C" {
    fn lex(ptr: *const u8, len: usize) -> RawVec<LexemeData>;
    fn parse(ptr: *const u8, len: usize) -> NodeData;
}

use parse as p;

impl Display for Gibberish {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "Gibberish")
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub struct Gibberish;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u32)]
pub enum GibberishToken {
    	KEYWORD,
	PARSER,
	TOKEN,
	HIGHTLIGHT,
	FOLD,
	Whitespace,
	Int,
	Colon,
	Comma,
	Bar,
	Dot,
	LBracket,
	RBracket,
	LParen,
	RParen,
	LBrace,
	RBrace,
	Plus,
	Eq,
	Ident,
	Semi,
	String,
	At,
	Err,

}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u32)]
pub enum GibberishSyntax {
    	Named = 0,
	CallName = 2,
	Args = 3,
	Call = 4,
	MemberCall = 5,
	Seq = 6,
	Choice = 7,
	KwDef = 9,
	TokenDef = 10,
	FoldStmt = 11,
	ParserDef = 12,
	ChildQuery = 13,
	GroupQuery = 14,
	Label = 15,
	LabelledQuery = 16,
	HighlightDef = 18,
	Root = 20,
	Unmatched = 21,

}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u32)]
pub enum GibberishLabel {
    	Expression,
	TokenName,
	Regex,
	ParserName,
	Declaration,

}

impl Display for GibberishToken {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{:?}", self)
    }
}

impl Display for GibberishSyntax {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{:?}", self)
    }
}

impl Display for GibberishLabel {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{:?}", self)
    }
}

impl Lang for Gibberish {
    type Token = GibberishToken;
    type Syntax = GibberishSyntax;
    type Label = GibberishLabel;
}

impl Gibberish {
    pub fn lex(text: &str) -> Vec<Lexeme<Gibberish>> {
        unsafe {
            Vec::from(lex(text.as_ptr(), text.len()))
                .into_iter()
                .map(|it| {
                    let temp = Lexeme::from_data(it, text);
                    mem::transmute(temp)
                })
                .collect()
        }
    }

    pub fn parse(text: &str) -> Node<Gibberish> {
        unsafe {
            let n = p(text.as_ptr(), text.len());
            mem::transmute(Node::from_data(n, text, &mut 0))
        }
    }
}
