use log::info;
use tracing::{error, info_span, warn};

use crate::runtime::{
    LexerParserState,
    parser::{
        api::{choice::Choice, just::Just, named::Named, rep::Rep, seq::Seq},
        node::Node,
        res::Res,
        state::State,
    },
};

pub mod api;
pub mod edit;
pub mod node;
pub mod res;
pub mod state;

#[derive(Debug, Clone)]
pub enum Parser {
    Just(Just),
    Choice(Choice),
    Seq(Seq),
    Rep(Rep),
    Named(Named),
}

impl<'a> Parser {
    pub fn kind(&self) -> String {
        match self {
            Parser::Just(t) => format!("just({t:?})"),
            Parser::Choice(_) => "choice".to_string(),
            Parser::Seq(_) => "seq".to_string(),
            Parser::Rep(_) => "rep".to_string(),
            Parser::Named { .. } => "named".to_string(),
        }
    }

    pub fn parse<'t>(&'a self, offset: usize, state: &mut State<'a, 't>) -> Res<'a> {
        match self {
            Parser::Just(token) => token.parse(offset, state),
            Parser::Choice(choice) => choice.parse(offset, state),
            Parser::Seq(seq) => seq.parse(offset, state),
            Parser::Rep(rep) => rep.parse(offset, state),
            Parser::Named(named) => named.parse(offset, state),
        }
    }

    fn try_parse<'t>(
        &'a self,
        offset: &mut usize,
        state: &mut State<'a, 't>,
        nodes: &mut Vec<Node<'a>>,
    ) -> Res<'a> {
        let _span = tracing::span!(tracing::Level::INFO, "try_parse", offset = offset).entered();

        let mut res = self.parse(*offset, state);
        while let Res::Err = res {
            if state.token_at(*offset).is_some() {
                *offset += 1;
                if let Some(Node::Unexpected(len)) = nodes.last_mut() {
                    *len += 1;
                } else {
                    error!("Created unexpected");
                    nodes.push(Node::Unexpected(1));
                }
            } else {
                let result = Res::Break(0);
                match &result {
                    Res::Ok(node) => info!("Result: {node:?}"),
                    Res::Err => info!("Result: Err"),
                    Res::Break(idx) => info!("Result: Break({})", idx),
                };
                return result;
            }
            res = self.parse(*offset, state);
        }
        match &res {
            Res::Ok(node) => info!("Result: {node:?}"),
            Res::Err => info!("Result: Err"),
            Res::Break(idx) => info!("Result: Break({})", idx),
        };
        res
    }

    fn peak<'t>(&self, offset: usize, state: &State<'a, 't>) -> bool {
        match self {
            Parser::Just(j) => j.peak(offset, state),
            Parser::Choice(c) => c.peak(offset, state),
            Parser::Seq(s) => s.peak(offset, state),
            Parser::Rep(r) => r.peak(offset, state),
            Parser::Named(n) => n.peak(offset, state),
        }
    }

    pub fn expected(&self) -> Vec<Expected> {
        match self {
            Parser::Just(j) => j.expected(),
            Parser::Choice(c) => c.expected(),
            Parser::Seq(s) => s.expected(),
            Parser::Rep(r) => r.expected(),
            Parser::Named(n) => n.expected(),
        }
    }
}

pub enum Expected {
    Token(u32),
    Syntax(u32),
}

impl Expected {
    pub fn get_str<'a>(&self, state: &LexerParserState<'a>) -> &'a str {
        match self {
            Expected::Token(id) => state.lexer.name_by_id(*id),
            Expected::Syntax(id) => state.name_by_id(*id),
        }
    }
}
