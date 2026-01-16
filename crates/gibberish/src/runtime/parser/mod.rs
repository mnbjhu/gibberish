use log::info;

use crate::runtime::{
    LexerParserState,
    parser::{node::Node, res::Res, state::State},
};

pub mod edit;
pub mod node;
pub mod res;
pub mod state;

#[derive(Debug, Clone)]
pub enum Parser {
    Just(u32),
    Choice(Vec<Parser>),
    Seq(Vec<Parser>),
    Rep(Box<Parser>),
    Named { name: u32, inner: Box<Parser> },
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

    pub fn parse<'t>(&'a self, mut offset: usize, state: &mut State<'a, 't>) -> Res<'a> {
        match self {
            Parser::Just(token) => {
                if let Some(current) = state.token_at(offset) {
                    if current == *token {
                        Res::Ok(Node::Token(*token))
                    } else if let Some(index) = state.get_break(offset) {
                        let b = index + 1;
                        Res::Break(b)
                    } else {
                        Res::Err
                    }
                } else {
                    Res::Break(0)
                }
            }
            Parser::Choice(parsers) => {
                let mut res = Res::Err;
                let mut index = 0;
                for (i, p) in parsers.iter().enumerate() {
                    res = p.parse(offset, state);
                    if matches!(res, Res::Ok(_)) {
                        index = i;
                        break;
                    }
                }
                if let Res::Ok(inner) = res {
                    Res::Ok(inner)
                } else {
                    res
                }
            }
            Parser::Seq(parsers) => {
                let mut nodes = vec![];
                let lowest_break = 1 + state.break_stack.len();
                let highest_break = lowest_break + parsers.len() - 2;
                parsers[1..]
                    .iter()
                    .rev()
                    .for_each(|it| state.break_stack.push(it));
                let mut res = parsers[0].parse(offset, state);
                if !matches!(res, Res::Ok(_)) {
                    parsers[1..].iter().for_each(|_| {
                        state.break_stack.pop();
                    });
                    if let Res::Break(index) = res
                        && index >= lowest_break
                    {
                        return Res::Err;
                    } else {
                        return res;
                    }
                }
                for (i, p) in parsers[1..].iter().enumerate() {
                    let break_index = highest_break - i;
                    state.break_stack.pop();
                    if let Res::Ok(node) = res {
                        offset += node.len();
                        nodes.push(node);
                        res = p.try_parse(&mut offset, state, &mut nodes);
                        if matches!(res, Res::Break(_)) {
                            nodes.push(Node::Missing(p));
                        }
                    } else if let Res::Break(index) = res
                        && index == break_index
                    {
                        res = p.try_parse(&mut offset, state, &mut nodes);
                        if matches!(res, Res::Break(_)) {
                            nodes.push(Node::Missing(p));
                        }
                    } else {
                        nodes.push(Node::Missing(p));
                    }
                }
                if let Res::Ok(node) = res {
                    nodes.push(node);
                }
                Res::Ok(Node::List {
                    len: nodes.iter().map(|it| it.len()).sum(),
                    items: nodes,
                })
            }
            Parser::Rep(inner) => {
                let mut items = vec![];
                state.break_stack.push(inner);
                let break_index = state.break_stack.len();
                let res = inner.parse(offset, state);
                match res {
                    Res::Ok(node) => {
                        offset += node.len();
                        items.push(node);
                    }
                    Res::Break(index) => {
                        state.break_stack.pop();
                        if index == break_index {
                            return Res::Err;
                        }
                        return Res::Break(index);
                    }
                    Res::Err => {
                        state.break_stack.pop();
                        return Res::Err;
                    }
                }
                finish_rep(&mut offset, state, inner, items)
            }
            Parser::Named { name, inner } => {
                state.checkpoints.push(state.break_stack.len());
                let res = match inner.parse(offset, state) {
                    Res::Ok(node) => {
                        let mut children = vec![];
                        node.add_into(&mut children);
                        Res::Ok(Node::Group {
                            kind: *name,
                            len: children.iter().map(Node::len).sum(),
                            children,
                        })
                    }
                    res => res,
                };
                state.checkpoints.pop();
                res
            }
        }
    }

    fn try_parse<'t>(
        &'a self,
        offset: &mut usize,
        state: &mut State<'a, 't>,
        nodes: &mut Vec<Node<'a>>,
    ) -> Res<'a> {
        let mut res = self.parse(*offset, state);
        while let Res::Err = res {
            if state.token_at(*offset).is_some() {
                *offset += 1;
                if let Some(Node::Unexpected(len)) = nodes.last_mut() {
                    *len += 1;
                } else {
                    nodes.push(Node::Unexpected(1));
                }
            } else {
                return Res::Break(0);
            }
            res = self.parse(*offset, state);
        }
        res
    }

    fn peak<'t>(&self, offset: usize, state: &State<'a, 't>) -> bool {
        match self {
            Parser::Just(token) => state.token_at(offset).is_some_and(|it| it == *token),
            Parser::Choice(parsers) => parsers.iter().any(|it| it.peak(offset, state)),
            Parser::Seq(parsers) => parsers.first().is_some_and(|it| it.peak(offset, state)),
            Parser::Rep(parser) => parser.peak(offset, state),
            Parser::Named { inner, .. } => inner.peak(offset, state),
        }
    }

    pub fn expected(&self) -> Vec<Expected> {
        match self {
            Parser::Just(tok) => {
                vec![Expected::Token(*tok)]
            }
            Parser::Choice(parsers) => parsers
                .iter()
                .flat_map(|it| it.expected().into_iter())
                .collect(),
            Parser::Seq(parsers) => parsers.first().unwrap().expected(),
            Parser::Rep(parser) => parser.expected(),
            Parser::Named { name, .. } => vec![Expected::Syntax(*name)],
        }
    }
}

pub fn finish_rep<'a, 't>(
    offset: &mut usize,
    state: &mut State<'a, 't>,
    inner: &'a Parser,
    mut items: Vec<Node<'a>>,
) -> Res<'a> {
    loop {
        let res = inner.try_parse(offset, state, &mut items);
        match res {
            Res::Ok(node) => {
                *offset += node.len();
                items.push(node);
            }
            _ => {
                state.break_stack.pop();
                return Res::Ok(Node::List {
                    len: items.iter().map(|it| it.len()).sum(),
                    items: items
                        .into_iter()
                        .flat_map(|it| {
                            if let Node::List { items, .. } = it {
                                items.into_iter()
                            } else {
                                vec![it].into_iter()
                            }
                        })
                        .collect(),
                });
            }
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
