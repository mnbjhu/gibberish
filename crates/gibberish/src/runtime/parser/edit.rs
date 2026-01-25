use std::iter::Peekable;

use crate::runtime::{
    lexer::edit::TokenEdit,
    parser::{node::Node, state::State},
};

pub struct ExistingInput<'a, I: Iterator<Item = Node<'a>>> {
    input: Peekable<I>,
    existing_offset: usize,
}

impl<'a, I: Iterator<Item = Node<'a>>> ExistingInput<'a, I> {
    pub fn peek(&mut self) -> Option<&Node<'a>> {
        self.input.peek()
    }

    pub fn next(&mut self) -> Option<Node<'a>> {
        let res = self.input.next();
        if let Some(res) = &res {
            self.existing_offset += res.len();
        }
        res
    }
}

pub struct EditState<'a, 't, 's> {
    offset: usize,
    edit: &'s TokenEdit,
    state: &'s mut State<'a, 't>,
}

#[cfg(test)]
mod tests {
    use crate::{
        assert_token_kind,
        runtime::{
            LexerParserState,
            build::RuntimeBuilder,
            lsp::build_parser,
            parser::{node::Node, res::Res},
        },
    };

    impl<'a> Node<'a> {
        fn as_group_name(&self, parser: &LexerParserState<'a>) -> &'a str {
            if let Node::Group { kind, .. } = self {
                parser.name_by_id(*kind)
            } else {
                panic!("Expected a group but found {}", self.name());
            }
        }

        fn as_token_name(&self, builder: &'a RuntimeBuilder) -> &'a str {
            if let Node::Token(res) = self {
                builder.lexer.name_by_id(*res)
            } else {
                panic!("Expected a token but found {}", self.name());
            }
        }
    }

    fn items_parser() -> RuntimeBuilder {
        build_parser(
            r#"
token whitespace = "\\s+";
token ident = "[a-zA-Z][a-zA-Z0-9]*";
token str = "'[^']*'";
token int = "[0-9]+";
token eq = "=";

parser expr = str | int;
parser stmt = expr + whitespace;
parser root = stmt.repeated();
"#,
        )
    }

    #[test]
    fn test() {
        let builder = items_parser();
        let mut parser = LexerParserState::new("123\n".to_string(), &builder);

        let Res::Ok(root) = &parser.node else {
            panic!("Expected Ok but got {:?}", &parser.node)
        };

        assert_eq!(root.as_group_name(&parser), "root");

        let Node::Group { children, len, .. } = root else {
            panic!("Expected a group")
        };

        // assert_eq!(*kind, builder.lexer.tokens.len() as u32);
        assert_eq!(*len, 2);
        assert_eq!(children.len(), 1);

        assert_eq!(children[0].as_token_name(&builder), "int");
        assert_eq!(children[1].as_token_name(&builder), "whitespace");
    }
}
