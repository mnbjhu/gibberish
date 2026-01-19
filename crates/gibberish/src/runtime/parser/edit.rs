use std::{iter::Peekable, ops::Range, ptr};

use tracing::{error, field, info, instrument};

use crate::runtime::{
    lexer::edit::TokenEdit,
    parser::{Parser, node::Node, res::Res, state::State},
};

impl Parser {
    pub fn from_existing<'a, 'i, 't, 's, I: Iterator<Item = Node<'a>>>(
        &'a self,
        input: &mut Peekable<I>,
    ) -> Option<Node<'a>> {
        if let Some(Node::Missing(p)) = input.peek() {
            if !ptr::eq(*p, self) {
                error!(
                    "Expected {current} but found {missing}",
                    current = self.kind(),
                    missing = p.kind()
                );
            }
            let result = input.next();
            match &result {
                Some(node) => info!("Result: {node:?}"),
                None => info!("Result: Err"),
            };
            return result;
        }
        match self {
            Parser::Just(_) | Parser::Named { .. } => input.next(),
            Parser::Choice(choice) => choice.from_existing(input),
            Parser::Seq(seq) => seq.from_existing(input),
            Parser::Rep(rep) => rep.from_existing(input),
        }
    }

    pub fn edit<'a, 't>(
        &'a self,
        offset: usize,
        node: Node<'a>,
        state: &mut State<'a, 't>,
        edit: &mut TokenEdit,
        changed: &mut Range<usize>,
    ) -> Res<'a> {
        info!("edit: {:?}", edit);
        if offset + node.len() < edit.remove.start || edit.remove.end <= offset {
            info!("Reusing {:?}", offset..offset + node.len());
            return Res::Ok(node);
        }
        if edit.remove.start <= offset {
            info!("Reparsing {:?}", offset..offset + node.len());
            return self.parse(offset, state).update_changed(offset, changed);
        }
        match (self, node) {
            (Parser::Choice(choice), node) => choice.edit(offset, node, state, edit, changed),
            (Parser::Just(_), Node::Token(_)) => {
                self.parse(offset, state).update_changed(offset, changed)
            }
            (Parser::Seq(_), Node::List { .. }) => {
                self.parse(offset, state).update_changed(offset, changed)
            }
            (Parser::Rep(rep), Node::List { items, .. }) => {
                rep.edit(offset, items, state, edit, changed)
            }

            (Parser::Named(named), Node::Group { children, .. }) => {
                named.edit(offset, children, state, edit, changed)
            }
            (_, _) => panic!("Unexpected parser/node combo"),
        }
    }

    #[allow(clippy::too_many_arguments)]
    pub fn try_edit<'a, 't, I: Iterator<Item = Node<'a>>>(
        &'a self,
        offset: &mut usize,
        next_existing_offset: &mut usize,
        input: &mut Peekable<I>,
        new: &mut Vec<Node<'a>>,
        state: &mut State<'a, 't>,
        edit: &mut TokenEdit,
        changed: &mut Range<usize>,
    ) -> Res<'a> {
        let _span = tracing::span!(
            tracing::Level::INFO,
            "try_edit",
            offset = offset,
            next = input.peek().map(|it| it.name())
        )
        .entered();

        loop {
            let next_offset = if *offset >= edit.remove.start {
                isize::try_from(*next_existing_offset).unwrap() + edit.change()
            } else {
                isize::try_from(*next_existing_offset).unwrap()
            };
            info!(
                name = "Existing check",
                offset,
                next_offset,
                edit = field::debug(&edit)
            );
            if next_offset < isize::try_from(*offset).unwrap() && input.peek().is_some() {
                let next = input.next().unwrap();
                info!("Skipping {next:?}");
                // *next_existing_offset += next.len();
                if next.len() > edit.remove.len() {
                    let insert = next.len() - edit.remove.len();
                    edit.remove.end = edit.remove.start;
                    edit.insert += insert;
                } else {
                    edit.remove.end -= next.len();
                }
                continue;
            }
            let res = if isize::try_from(*offset).unwrap() == next_offset
                && let Some(next) = self.from_existing(input)
            {
                let before_len = next.len();
                let end = *offset + before_len;

                // If the edit's remove contains 'next' we just delete it from the tree
                if edit.remove.start <= *offset && end <= edit.remove.end {
                    info!("Deleting {:?}", *offset..end);
                    edit.remove.end -= next.len();
                    continue;
                }
                *next_existing_offset += next.len();

                // If we're before or after the edit we can just use the existing
                if edit.remove.start >= end || edit.remove.end <= *offset {
                    info!("Reusing (try) {:?}", *offset..end);
                    if let Node::Unexpected(n) = next {
                        *offset += n;
                        new.push(Node::Unexpected(n));
                        continue;
                    } else {
                        let result = Res::Ok(next);
                        match &result {
                            Res::Ok(node) => info!("Result: {node:?}"),
                            Res::Err => info!("Result: Err"),
                            Res::Break(idx) => info!("Result: Break({})", idx),
                        };
                        return result;
                    }
                }

                if *offset <= edit.remove.start && edit.remove.start < end {
                    // If the the edit starts in the item then perform an edit
                    info!("Editing (try) {:?}", *offset..end);
                    self.edit(*offset, next, state, edit, changed)
                } else {
                    info!("Reparsing (try) {:?}", *offset..end);
                    self.parse(*offset, state).update_changed(*offset, changed)
                }
            } else {
                self.parse(*offset, state).update_changed(*offset, changed)
            };
            if !matches!(res, Res::Err) {
                match &res {
                    Res::Ok(node) => info!("Result: {node:?}"),
                    Res::Err => info!("Result: Err"),
                    Res::Break(idx) => info!("Result: Break({})", idx),
                };
                return res;
            } else if let Some(Node::Unexpected(n)) = new.last_mut() {
                *n += 1;
                *offset += 1;
            } else {
                *offset += 1;
                error!("Bump error");
                new.push(Node::Unexpected(1));
            }
        }
    }

    pub fn peak_edit<'a>(&'a self, node: &Node<'a>) -> bool {
        match self {
            Parser::Just(tok) => tok.peak_edit(node),
            Parser::Choice(c) => c.peak_edit(node),
            Parser::Seq(s) => s.peak_edit(node),
            Parser::Rep(r) => r.peak_edit(node),
            Parser::Named(n) => n.peak_edit(node),
        }
    }
}

impl<'a> Res<'a> {
    pub fn map(self, f: impl Fn(Node<'a>) -> Node<'a>) -> Res<'a> {
        match self {
            Res::Ok(node) => Res::Ok(f(node)),
            res => res,
        }
    }

    /// Returns a string description of the result kind for logging
    pub fn kind(&self) -> &'static str {
        match self {
            Res::Ok(_) => "Ok",
            Res::Err => "Err",
            Res::Break(_) => "Break",
        }
    }
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
