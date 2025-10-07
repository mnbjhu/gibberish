use std::{
    collections::HashMap,
    fmt::{Debug, Display},
    ops::Index,
};

use regex::Regex;

use crate::{
    api::ptr::ParserIndex,
    dsl::ast::{AssignableAst, RootAst},
    parser::{lang::Lang, node::Lexeme},
};

#[derive(Default)]
pub struct RuntimeLexer {
    pub tokens: Vec<(String, Regex)>,
}

pub fn build_lexer<'a>(ast: RootAst<'a>) -> RuntimeLexer {
    let mut lexer = RuntimeLexer::default();
    ast.iter()
        .filter_map(|it| {
            if let AssignableAst::Token(t) = it.expr() {
                let mut r = t
                    .text
                    .strip_prefix("\"")
                    .unwrap()
                    .strip_suffix("\"")
                    .unwrap()
                    .to_string();
                r.insert(0, '^');
                Some((&it.name().text, r))
            } else {
                None
            }
        })
        .for_each(|(name, text)| {
            let r = Regex::new(&text);
            lexer.tokens.push((name.to_string(), r.unwrap()));
        });
    lexer
}

#[derive(Clone, Copy)]
pub struct RuntimeLang<'a> {
    pub lexer: &'a RuntimeLexer,
    pub vars: &'a [(String, ParserIndex<RuntimeLang<'a>>)],
}

impl Debug for RuntimeLang<'_> {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("RuntimeLang").finish()
    }
}

impl PartialEq for RuntimeLang<'_> {
    fn eq(&self, other: &Self) -> bool {
        std::ptr::eq(self, other)
    }
}

impl Eq for RuntimeLang<'_> {}

impl Display for RuntimeLang<'_> {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "RuntimeLang")
    }
}

impl<'a> std::hash::Hash for RuntimeLang<'a> {
    fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
        std::ptr::hash(self, state);
    }
}

impl<'a> Lang for RuntimeLang<'a> {
    type Token = u32;

    type Syntax = u32;

    fn lex(&self, src: &str) -> Vec<crate::parser::node::Lexeme<Self>>
    where
        Self: Sized,
    {
        let mut text = src;
        let mut offset = 0;
        let mut res = vec![];
        'outer: loop {
            if text.is_empty() {
                return res;
            }
            for (index, (_, parser)) in self.lexer.tokens.iter().enumerate() {
                if let Some(captures) = parser.captures(text) {
                    let whole = captures[0].to_string();
                    let len = whole.len();
                    res.push(Lexeme {
                        span: offset..(offset + len),
                        kind: index as u32,
                        text: whole,
                    });
                    offset += len;
                    text = &text[len..];
                    continue 'outer;
                }
            }
            let err_index = self.lexer.tokens.len();
            if let Some(Lexeme {
                span,
                kind,
                text: t,
            }) = res.last_mut()
                && *kind as usize == err_index
            {
                offset += 1;
                span.end = offset;
                t.push(text.chars().next().unwrap());
                text = &text[1..];
            } else {
                res.push(Lexeme {
                    span: offset..(offset + 1),
                    kind: err_index as u32,
                    text: text.chars().next().unwrap().to_string(),
                });
                offset += 1;
                text = &text[1..];
            }
        }
    }

    fn root() -> Self::Syntax {
        0
    }

    fn token_name(&self, token: &Self::Token) -> String {
        self.lexer.tokens.get(*token as usize).unwrap().0.clone()
    }

    fn syntax_name(&self, syntax: &Self::Syntax) -> String {
        self.vars.get(*syntax as usize).unwrap().0.clone()
    }
}
