use crate::parser::{lang::Lang, node::Node};

pub enum Query<L: Lang, T: Clone> {
    Group {
        name: L::Syntax,
        children: Vec<Query<L, T>>,
    },
    Token {
        kind: L::Token,
    },
    Data {
        query: Box<Query<L, T>>,
        data: T,
    },
}

impl<L: Lang> Node<L> {
    pub fn query_exact<'a, T: Clone>(
        &'a self,
        query: &Query<L, T>,
        results: &mut Vec<(&'a Node<L>, T)>,
    ) -> bool {
        let q = if let Query::Data { query, .. } = query {
            query
        } else {
            query
        };
        let res = match self {
            Node::Group(group) => {
                if let Query::Group { name, children } = q
                    && group.kind == *name
                {
                    let mut index = 0;
                    let mut res = true;
                    'outer: for child_query in children {
                        loop {
                            let Some(child_node) = group.children.get(index) else {
                                res = false;
                                break 'outer;
                            };
                            index += 1;
                            if child_node.query_exact(child_query, results) {
                                continue 'outer;
                            }
                        }
                    }
                    res
                } else {
                    false
                }
            }
            Node::Lexeme(lexeme) => {
                if let Query::Token { kind } = q
                    && *kind == lexeme.kind
                {
                    true
                } else {
                    false
                }
            }
            Node::Err(_) => false,
        };
        if let Query::Data { data, .. } = query
            && res
        {
            results.push((self, data.clone()));
        };
        res
    }

    pub fn query_all<'a, T: Clone>(
        &'a self,
        query: &Query<L, T>,
        results: &mut Vec<(&'a Node<L>, T)>,
    ) {
        match self {
            Node::Group(group) => {
                self.query_exact(query, results);
                for child in &group.children {
                    child.query_all(query, results);
                }
            }
            _ => {
                self.query_exact(query, results);
            }
        }
    }

    pub fn query<'a, T: Clone>(&'a self, query: &Query<L, T>) -> Vec<(&'a Node<L>, T)> {
        let mut res = vec![];
        self.query_all(query, &mut res);
        res
    }
}
