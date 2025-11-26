use std::fmt::{Debug, Display};

use gibberish_core::{lang::Lang, node::Lexeme};
use regex::Regex;

use crate::{
    api::ptr::ParserIndex,
    dsl::ast::{
        RootAst,
        stmt::{StmtAst, keyword::KeywordDefAst, token::TokenDefAst},
    },
};

pub mod build;
pub mod choice;
pub mod exact;
pub mod group;
pub mod option;
pub mod seq;

#[derive(Default, Clone)]
pub struct RuntimeLexer {
    pub tokens: Vec<(String, Regex)>,
    pub keywords: Vec<usize>,
}

pub fn build_lexer<'a>(ast: RootAst<'a>, src: &str, filename: &str) -> RuntimeLexer {
    let mut lexer = RuntimeLexer::default();
    for stmt in ast.iter() {
        match stmt {
            StmtAst::Token(token_def_ast) => token_def_ast.build(&mut lexer, src, filename),
            StmtAst::Keyword(keyword_def_ast) => keyword_def_ast.build(&mut lexer),
            _ => {}
        }
    }
    lexer
}

impl<'a> TokenDefAst<'a> {
    fn build(&self, lexer: &mut RuntimeLexer, src: &str, filename: &str) {
        let value = self.value().unwrap();
        let mut text = value.text.clone();
        text.remove(0);
        text.pop();
        text.insert(0, '^');
        text = text.replace("\\\\", "\\");
        text = text.replace("\\\"", "\"");
        text = text.replace("\\n", "\n");
        text = text.replace("\\t", "\t");
        text = text.replace("\\f", "\x0C");
        // match Regex::new(&text) {
        //     Ok(regex) => {
        //         lexer.tokens.push((self.name().text.clone(), regex));
        //     }
        //     Err(err) => {
        //         report_simple_error(
        //             &format!("Regex error: {err}"),
        //             value.span.clone(),
        //             src,
        //             filename,
        //         );
        //         lexer.tokens.push((
        //             self.name().text.clone(),
        //             Regex::new("TODO: SOME ACTUAL REGEX").unwrap(),
        //         ));
        //     }
        // }
        lexer.tokens.push((
            self.name().text.clone(),
            Regex::new("TODO: SOME ACTUAL REGEX").unwrap(),
        ));
    }
}

impl<'a> KeywordDefAst<'a> {
    fn build(&self, lexer: &mut RuntimeLexer) {
        let regex = format!("^({})[^_a-zA-Z]", self.name().text);
        let id = lexer.tokens.len();
        lexer.keywords.push(id);
        lexer
            .tokens
            .push((self.name().text.clone(), Regex::new(&regex).unwrap()));
    }
}

#[derive(Clone)]
pub struct RuntimeLang {
    pub lexer: RuntimeLexer,
    pub vars: Vec<(String, ParserIndex<RuntimeLang>)>,
}

impl Debug for RuntimeLang {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("RuntimeLang").finish()
    }
}

impl PartialEq for RuntimeLang {
    fn eq(&self, other: &Self) -> bool {
        std::ptr::eq(self, other)
    }
}

impl Eq for RuntimeLang {}

impl Display for RuntimeLang {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "RuntimeLang")
    }
}

impl std::hash::Hash for RuntimeLang {
    fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
        std::ptr::hash(self, state);
    }
}

impl Lang for RuntimeLang {
    type Token = u32;

    type Syntax = u32;

    fn lex(&self, src: &str) -> Vec<Lexeme<Self>>
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
            for (index, (name, parser)) in self.lexer.tokens.iter().enumerate() {
                if let Some(captures) = parser.captures(text) {
                    let whole = captures
                        .iter()
                        .last()
                        .unwrap_or_else(|| panic!("No caputure groups found for {name} regex"));

                    let whole = whole.unwrap().as_str().to_string();
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
                let index = text.char_indices().nth(1).unwrap().0;
                text = &text[index..];
            }
        }
    }

    fn root(&self) -> Self::Syntax {
        self.vars.len().saturating_sub(1) as u32
    }

    fn token_name(&self, token: &Self::Token) -> String {
        self.lexer
            .tokens
            .get(*token as usize)
            .map(|it| it.0.as_str())
            .unwrap_or("ERR")
            .to_string()
    }

    fn syntax_name(&self, syntax: &Self::Syntax) -> String {
        self.vars.get(*syntax as usize).unwrap().0.clone()
    }
}
