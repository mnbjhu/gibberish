use crate::runtime::{
    lexer::{Lexer, edit::TextEdit, state::LexerState},
    parser::{Parser, res::Res, state::State},
};

pub mod build;
pub mod lexer;
pub mod lsp;
pub mod parser;

pub struct LexerParserState<'a> {
    lexer: &'a Lexer,
    parser: &'a Parser,
    lexer_state: LexerState,
    node: Res<'a>,
}

impl<'a> LexerParserState<'a> {
    pub fn new(text: String, lexer: &'a Lexer, parser: &'a Parser) -> Self {
        let lexer_state = lexer.lex(text);
        let mut state = State {
            tokens: &lexer_state.tokens,
            break_stack: vec![],
            checkpoints: vec![],
        };
        let res = parser.parse(0, &mut state);
        Self {
            lexer,
            parser,
            lexer_state,
            node: res,
        }
    }

    pub fn edit(&mut self, edit: &TextEdit) {
        self.lexer_state.edit(self.lexer, edit);
        let mut state = State {
            tokens: &self.lexer_state.tokens,
            break_stack: vec![],
            checkpoints: vec![],
        };
        let res = self.parser.parse(0, &mut state);
        self.node = res;
    }
}
