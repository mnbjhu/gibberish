use crate::runtime::parser::Parser;

#[derive(Debug)]
pub enum Node<'a> {
    Unexpected(usize),
    Missing(&'a Parser),
    Token(&'a Parser),
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
            Node::Token(_) => 1,
            Node::List { len, .. } => *len,
            Node::Group { len, .. } => *len,
        }
    }

    #[must_use]
    pub fn is_empty(&self) -> bool {
        self.len() == 0
    }
}
