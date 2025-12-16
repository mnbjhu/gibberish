
use std::{fmt::Display, mem};

use gibberish_core::{
    lang::Lang,
    node::{Lexeme, LexemeData, Node},
    state::{State, StateData},
    vec::{RawVec, SliceData},
};

#[link(name = "gibberish-parser", kind = "static")]
unsafe extern "C" {
    fn lex(ptr: *const u8, len: usize) -> RawVec<LexemeData>;
    fn default_state_ptr(ptr: *const u8, len: usize) -> *const StateData;
    fn parse(ptr: *const StateData) -> u32;
    fn get_state(ptr: *const StateData) -> StateData;
    fn token_name(id: u32) -> SliceData;
    fn group_name(id: u32) -> SliceData;
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
	Root = 21,
	Unmatched = 22,

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

impl Lang for Gibberish {
    type Token = GibberishToken;
    type Syntax = GibberishSyntax;

    fn lex(&self, src: &str) -> Vec<Lexeme<Self>> {
        todo!()
    }

    fn root(&self) -> Self::Syntax {
        todo!()
    }

    // fn token_name(&self, token: &Self::Token) -> String {
    //     let slice: &str = unsafe { token_name(*token) }.into();
    //     slice.to_string()
    // }
    //
    // fn syntax_name(&self, syntax: &Self::Syntax) -> String {
    //     let slice: &str = unsafe { group_name(*syntax) }.into();
    //     slice.to_string()
    // }
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
            let state_ptr = default_state_ptr(text.as_ptr(), text.len());
            p(state_ptr);
            let state_data = get_state(state_ptr);
            let mut state = State::from_data(state_data, text);
            assert_eq!(state.stack.len(), 1);
            mem::transmute(state.stack.pop().unwrap())
        }
    }
}
