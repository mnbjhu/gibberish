use std::fmt::Display;

use crate::api::{
    choice::choice,
    just::just,
    ptr::{ParserCache, ParserIndex},
    rec::recursive,
};

use logos::Logos;

use crate::parser::{lang::Lang, node::Lexeme};

#[derive(Debug, PartialEq, Eq, Clone, Copy, Hash)]
pub struct DslLang;

impl Lang for DslLang {
    type Token = DslToken;
    type Syntax = DslSyntax;

    fn lex(&self, src: &str) -> Vec<Lexeme<Self>> {
        let mut lexer = DslToken::lexer(src);
        let mut found = vec![];
        while let Some(next) = lexer.next() {
            match next {
                Ok(next) => {
                    let lexeme = Lexeme {
                        span: lexer.span(),
                        kind: next,
                        text: lexer.slice().to_string(),
                    };
                    found.push(lexeme);
                }
                Err(_) => {
                    let lexeme = Lexeme {
                        span: lexer.span(),
                        kind: DslToken::Err,
                        text: lexer.slice().to_string(),
                    };
                    found.push(lexeme);
                }
            }
        }
        found
    }

    fn root() -> DslSyntax {
        DslSyntax::Root
    }
}

#[derive(logos::Logos, Debug, PartialEq, Eq, Clone, Hash)]
#[logos(skip r"[ \t\n\f]+")]
pub enum DslToken {
    #[regex("\"[^\"]*\"")]
    String,
    #[regex("k\"[^\"]*\"")]
    KwString,
    #[regex(r"[0-9]+")]
    Int,
    #[token(":")]
    Colon,
    #[token(",")]
    Comma,
    #[token("|")]
    Bar,
    #[token("[")]
    LBracket,
    #[token("]")]
    RBracket,
    #[token("(")]
    LParen,
    #[token(")")]
    RParen,
    #[token("{")]
    LBrace,
    #[token("}")]
    RBrace,
    #[token("+")]
    Plus,
    #[token("*")]
    Mul,

    #[token("=")]
    Eq,

    #[regex("[_a-zA-Z][_a-zA-Z0-9]*")]
    Ident,

    #[token(";")]
    Semi,

    Err,
}

#[derive(Debug, PartialEq, Eq, Clone, Copy, Hash)]
pub enum DslSyntax {
    String,
    Number,
    Field,
    Array,
    Object,
    Root,
    Key,
    Add,
    Name,
    Seq,
    Choice,
    Assignment,
    Call,
    Args,
}

impl Display for DslSyntax {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            DslSyntax::String => f.write_str("String"),
            DslSyntax::Number => f.write_str("Number"),
            DslSyntax::Field => f.write_str("Field"),
            DslSyntax::Array => f.write_str("Array"),
            DslSyntax::Object => f.write_str("Object"),
            DslSyntax::Root => f.write_str("Root"),
            DslSyntax::Key => f.write_str("Key"),
            DslSyntax::Add => f.write_str("Add"),
            DslSyntax::Name => f.write_str("Name"),
            DslSyntax::Seq => f.write_str("Seq"),
            DslSyntax::Choice => f.write_str("Choice"),
            DslSyntax::Assignment => f.write_str("Assignment"),
            DslSyntax::Call => f.write_str("Call"),
            DslSyntax::Args => f.write_str("Args"),
        }
    }
}

impl Display for DslToken {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            DslToken::String => f.write_str("String"),
            DslToken::Int => f.write_str("Int"),
            DslToken::Colon => f.write_str("Colon"),
            DslToken::Comma => f.write_str("Comma"),
            DslToken::LBracket => f.write_str("LBracket"),
            DslToken::RBracket => f.write_str("RBracket"),
            DslToken::LBrace => f.write_str("LBrace"),
            DslToken::RBrace => f.write_str("RBrace"),
            DslToken::Plus => f.write_str("Plus"),
            DslToken::Mul => f.write_str("Mul"),
            DslToken::Ident => f.write_str("Ident"),
            DslToken::Eq => f.write_str("Eq"),
            DslToken::LParen => f.write_str("LParen"),
            DslToken::RParen => f.write_str("RParen"),
            DslToken::Bar => f.write_str("Bar"),
            DslToken::Err => f.write_str("Err"),
            DslToken::Semi => f.write_str("Semi"),
            DslToken::KwString => f.write_str("KwString"),
        }
    }
}

impl Display for DslLang {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "DslLang")
    }
}

pub fn dsl_parser(cache: &mut ParserCache<DslLang>) -> ParserIndex<DslLang> {
    use DslSyntax as S;
    use DslToken as T;

    let expr = recursive(
        |expr, cache| {
            let name = just(T::Ident, cache).named(S::Name, cache);
            let func_args = expr
                .sep_by(just(T::Comma, cache), cache)
                .delim_by(just(T::LParen, cache), just(T::RParen, cache), cache)
                .named(S::Args, cache);
            let func = name.fold_once(S::Call, func_args, cache);
            let brackets = expr.delim_by(just(T::LParen, cache), just(T::RParen, cache), cache);
            let atom = choice(vec![func, brackets], cache);
            let seq = atom.fold(S::Seq, just(T::Plus, cache).then(atom, cache), cache);
            let choice = seq.fold(S::Choice, just(T::Bar, cache).then(seq, cache), cache);
            choice
        },
        cache,
    );

    let assignable = choice(vec![just(T::String, cache), expr], cache);
    just(DslToken::Ident, cache)
        .then(just(DslToken::Eq, cache), cache)
        .then(assignable, cache)
        .named(S::Assignment, cache)
        .sep_by(just(DslToken::Semi, cache), cache)
}
