
use std::{fmt::Display, mem};

use gibberish_core::{
    lang::Lang,
    node::{Lexeme, LexemeData, Node, NodeData},
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
	Comment,
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
	Bracketed = 1,
	CallName = 3,
	Args = 4,
	Call = 5,
	MemberCall = 6,
	Seq = 7,
	Choice = 8,
	KwDef = 10,
	TokenDef = 11,
	FoldStmt = 12,
	ParserDef = 13,
	ChildQuery = 14,
	GroupQuery = 15,
	Label = 16,
	LabelledQuery = 17,
	HighlightDef = 19,
	Root = 21,
	Unmatched = 22,

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
