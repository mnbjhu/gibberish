use std::{
    cmp::{max, min},
    collections::HashMap,
    ops::Range,
};
use tracing::{debug, info};

use crate::runtime::{
    build::RuntimeBuilder,
    lexer::{
        Lexer,
        edit::{TextEdit, TokenEdit},
        state::LexerState,
        token::Tok,
    },
    parser::{Parser, res::Res, state::State},
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

impl<'a> Res<'a> {
    pub fn update_changed(self, offset: usize, changed: &mut Range<usize>) -> Res<'a> {
        if let Res::Ok(node) = self {
            if *changed == (0..0) {
                *changed = offset..offset + node.len()
            } else {
                changed.start = min(changed.start, offset);
                changed.end = max(changed.end, offset + node.len())
            }
            Res::Ok(node)
        } else {
            self
        }
    }
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
        let before_tokens = self.lexer_state.tokens.clone(); // TODO: For debugging
        let mut edit = self.lexer_state.edit(self.lexer, edit);
        info!(
            "Removed: [{removed}], Inserted: [{inserted}]",
            removed = token_text(&before_tokens[edit.remove.clone()], self.lexer),
            inserted = token_text(
                &self.lexer_state.tokens[edit.remove.start..edit.remove.start + edit.insert],
                self.lexer
            )
        );
        let mut state = State {
            tokens: &self.lexer_state.tokens,
            break_stack: vec![],
            checkpoints: vec![],
        };
        let mut changed = 0..0;
        self.node = if let Res::Ok(node) = self.node.pop() {
            self.parser
                .edit(0, node, &mut state, &mut edit, &mut changed)
        } else {
            self.parser.parse(0, &mut state)
        };
        EditStats { changed, edit }
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

fn token_text(tokens: &[Tok], lexer: &Lexer) -> String {
    let mut res = String::new();
    for (index, t) in tokens.iter().enumerate() {
        if index == 0 {
            res += lexer.name_by_id(t.kind)
        } else {
            res += " ,";
            res += lexer.name_by_id(t.kind)
        }
    }
    res
}

#[derive(Debug)]
pub struct EditStats {
    changed: Range<usize>,
    edit: TokenEdit,
}
