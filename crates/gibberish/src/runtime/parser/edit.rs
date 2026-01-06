use std::iter::Peekable;

use tracing::info;

use crate::runtime::{
    lexer::edit::TokenEdit,
    parser::{Parser, node::Node, res::Res, state::State},
};

impl Parser {
    /// Edits an existing parse tree node.
    ///
    /// - `node`: The node to edit
    /// - `index`: The starting position in the text
    /// - `edit`: The edit to apply
    /// - `state`: The parser state
    pub fn edit<'a, 't>(
        &'a self,
        node: Node<'a>,
        mut offset: usize,
        mut edit: TokenEdit,
        state: &mut State<'a, 't>,
    ) -> Res<'a> {
        // Early return if the edit is empty or node is entirely before the edit
        let node_len = node.len();
        let node_end = offset + node_len;

        if edit.is_empty() || node_end <= edit.remove.start {
            return Res::Ok(node);
        }

        // If the node is after the edit, it shouldn't be modified
        if offset >= edit.remove.end {
            return Res::Ok(node);
        }

        info!("Editing {self:#?} at {offset}",);
        match self {
            Parser::Choice(parsers) => {
                let option = parsers.iter().find(|it| it.peak_edit(&node));
                if let Some(option) = option
                    && let Res::Ok(node) = option.edit(node, offset, edit, state)
                {
                    return Res::Ok(node);
                }
                self.parse(offset, state)
            }
            Parser::Named { name, .. } => {
                if let Node::Group { kind, .. } = &node
                    && kind == name
                {
                    Res::Ok(node)
                } else {
                    self.parse(offset, state)
                }
            }
            Parser::Seq(parsers) => todo!(),
            Parser::Just(token) => {
                todo!()
            }
            Parser::Rep(inner) => {
                todo!()
            }
        }
    }

    pub fn edit_from_iter<'a, 't>(
        &'a self,
        existing: &mut Peekable<impl Iterator<Item = Node<'a>>>,
        mut index: usize,
        state: &mut State<'a, 't>,
    ) -> Res<'a> {
        todo!()
    }

    pub fn try_edit<'a, 't>(
        &'a self,
        existing: &mut Peekable<impl Iterator<Item = Node<'a>>>,
        new: &mut Vec<Node<'a>>,
        index: &mut usize,
        edit: &mut TokenEdit,
        state: &mut State<'a, 't>,
    ) -> Res<'a> {
        todo!()
    }

    pub fn peak_edit<'a>(&'a self, node: &Node<'a>) -> bool {
        match self {
            Parser::Just(tok) => {
                if let Node::Token(id) = node {
                    tok == id
                } else {
                    false
                }
            }
            Parser::Choice(parsers) => parsers.iter().any(|it| it.peak_edit(node)),
            Parser::Seq(parsers) => parsers.first().unwrap().peak_edit(node),
            Parser::Rep(parser) => parser.peak_edit(node),
            Parser::Named { name, .. } => {
                if let Node::Group { kind, .. } = node {
                    name == kind
                } else {
                    false
                }
            }
        }
    }
}

impl<'a> Res<'a> {
    pub fn map(self, f: fn(Node<'a>) -> Node<'a>) -> Res<'a> {
        match self {
            Res::Ok(node) => Res::Ok(f(node)),
            res => res,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::runtime::lexer::token::Tok;

    #[test]
    fn test_edit_token_node() {
        // Create a token node and a token edit
        let node = Node::Token(42);
        let edit = TokenEdit {
            remove: 0..0, // Empty edit
            insert: 0,
        };

        // Create a parser that matches the token
        let parser = Parser::Just(42);

        // Create a minimal state
        let tokens: Vec<Tok> = Vec::new(); // Empty tokens for test
        let mut state = State {
            tokens: &tokens,
            checkpoints: Vec::new(),
            break_stack: Vec::new(),
        };

        // Test editing with an empty edit (should pass through unchanged)
        let result = parser.edit(node, 0, edit, &mut state);

        // The edit should succeed and return the same token
        assert!(matches!(result, Res::Ok(Node::Token(42))));
    }

    #[test]
    fn test_edit_list_node() {
        // Create a list node with token items
        let items = vec![Node::Token(1), Node::Token(2), Node::Token(3)];
        let node = Node::List {
            items: items,
            len: 3,
        };

        // Create an empty edit (just for testing the method logic)
        let edit = TokenEdit {
            remove: 0..0,
            insert: 0,
        };

        // Create a parser that contains the tokens
        let parser = Parser::Rep(Box::new(Parser::Just(1)));

        // Create a minimal state
        let tokens: Vec<Tok> = Vec::new(); // Empty tokens for test
        let mut state = State {
            tokens: &tokens,
            checkpoints: Vec::new(),
            break_stack: Vec::new(),
        };

        // Test the Node::edit method for List
        let (result, _) = node.edit(0, &edit, &mut state);

        // The result should be a successful edit that preserves the list structure
        assert!(result.is_some());
        if let Some(Res::Ok(Node::List { items, .. })) = result {
            assert_eq!(items.len(), 3);
        } else {
            panic!("Result should be Some(Res::Ok(Node::List))");
        }
    }
}
