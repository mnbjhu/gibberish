use std::collections::HashMap;

use tracing::debug;

use crate::{
    ast::builder::ParserBuilder,
    runtime::{
        build::RuntimeBuilder,
        lexer::{
            Lexer,
            edit::{TextEdit, TokenEdit},
            state::LexerState,
        },
        parser::{Parser, res::Res, state::State},
    },
};

pub mod build;
pub mod cmd;
pub mod lexer;
pub mod lsp;
pub mod parser;

pub struct LexerParserState<'a> {
    lexer: &'a Lexer,
    parser: &'a Parser,
    named: &'a HashMap<u32, String>,
    lexer_state: LexerState,
    node: Res<'a>,
}

impl<'a> LexerParserState<'a> {
    pub fn name_by_id(&self, id: u32) -> &'a str {
        self.named.get(&id).unwrap()
    }
    pub fn new(text: String, builder: &'a RuntimeBuilder) -> Self {
        debug!("Building parser state");
        let lexer_state = builder.lexer.lex(text);
        debug!("Built lexer_state");
        let mut state = State {
            tokens: &lexer_state.tokens,
            break_stack: vec![],
            checkpoints: vec![],
        };
        let parser = builder.parsers.get("root").unwrap();
        let res = parser.parse(0, &mut state);
        debug!("Built node");
        Self {
            lexer: &builder.lexer,
            parser,
            lexer_state,
            named: &builder.named,
            node: res,
        }
    }

    pub fn lexer_edit_reparse(&mut self, edit: &TextEdit) {
        self.lexer_state.edit(self.lexer, edit);
        let mut state = State {
            tokens: &self.lexer_state.tokens,
            break_stack: vec![],
            checkpoints: vec![],
        };
        let res = self.parser.parse(0, &mut state);
        self.node = res;
    }

    pub fn edit(&mut self, edit: &TextEdit) -> EditStats {
        let edit = self.lexer_state.edit(self.lexer, edit);
        let mut state = State {
            tokens: &self.lexer_state.tokens,
            break_stack: vec![],
            checkpoints: vec![],
        };
        let mut s = None;
        self.node = if let Res::Ok(node) = self.node.pop()
            && let (Some(res), start) = node.edit(0, &edit, &mut state)
        {
            s = start;
            res
        } else {
            self.parser.parse(0, &mut state)
        };
        EditStats {
            start_index: s.unwrap_or(0),
            edit,
        }
    }

    pub fn parse(&mut self, text: String) {
        debug!("Building parser state");
        self.lexer_state = self.lexer.lex(text);
        debug!("Built lexer_state");
        let mut state = State {
            tokens: &self.lexer_state.tokens,
            break_stack: vec![],
            checkpoints: vec![],
        };
        self.node = self.parser.parse(0, &mut state);
    }
}

#[derive(Debug)]
pub struct EditStats {
    start_index: usize,
    edit: TokenEdit,
}
