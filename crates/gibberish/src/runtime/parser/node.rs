use std::io::Write;

use crate::runtime::{LexerParserState, parser::Parser};

#[derive(Debug)]
pub enum Node<'a> {
    Unexpected(usize),
    Missing(&'a Parser),
    Token,
    List {
        items: Vec<Node<'a>>,
        len: usize,
    },
    Group {
        kind: u32,
        children: Vec<Node<'a>>,
        len: usize,
        parser: &'a Parser,
        breaks_from_parent: Vec<&'a Parser>,
    },
}

impl<'a> Node<'a> {
    pub fn add_into(self, items: &mut Vec<Node<'a>>) {
        if let Node::List { items: i, .. } = self {
            items.extend(i);
        } else {
            items.push(self);
        }
    }

    pub fn len(&self) -> usize {
        match self {
            Node::Unexpected(len) => *len,
            Node::Missing(_) => 0,
            Node::Token => 1,
            Node::List { len, .. } => *len,
            Node::Group { len, .. } => *len,
        }
    }

    #[must_use]
    pub fn is_empty(&self) -> bool {
        self.len() == 0
    }

    pub fn fmt_at(
        &self,
        f: &mut impl Write,
        indent: usize,
        mut offset: usize,
        state: &LexerParserState<'a>,
    ) -> std::io::Result<()> {
        write_indent(indent, f)?;
        match self {
            Node::Unexpected(len) => {
                writeln!(f, "unexpected")?;
                for tok in &state.lexer_state.tokens[offset..offset + *len] {
                    write_indent(indent + 1, f)?;
                    writeln!(f, "{}", state.lexer.name_by_id(tok.kind))?;
                }
                Ok(())
            }
            Node::Missing(e) => {
                writeln!(
                    f,
                    "Missing: {}",
                    e.expected()
                        .iter()
                        .map(|it| it.get_str(state))
                        .collect::<Vec<_>>()
                        .join(", ")
                )
            }
            Node::Token => {
                let kind = state.lexer_state.tokens[offset].kind;
                writeln!(f, "{}", state.lexer.name_by_id(kind))
            }
            Node::Group { kind, children, .. } => {
                writeln!(f, "{}", state.name_by_id(*kind))?;
                for item in children {
                    item.fmt_at(f, indent + 1, offset, state)?;
                    offset += item.len();
                }
                Ok(())
            }
            Node::List { items, len } => todo!(),
        }
    }
}
fn write_indent(offset: usize, f: &mut impl Write) -> std::io::Result<()> {
    for _ in 0..offset {
        write!(f, "  ")?
    }
    Ok(())
}
