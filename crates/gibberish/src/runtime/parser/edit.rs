use std::{iter::Peekable, ops::Range, ptr};

use log::warn;
use tracing::{Level, error, info, info_span, span};

use crate::runtime::{
    lexer::edit::TokenEdit,
    parser::{Parser, node::Node, res::Res, state::State},
};

impl Parser {
    pub fn from_existing<'a, 'i, 't, 's, I: Iterator<Item = Node<'a>>>(
        &'a self,
        input: &mut Peekable<I>,
    ) -> Option<Node<'a>> {
        let _span = match self {
            Parser::Just(token) => tracing::span!(
                tracing::Level::INFO,
                "from_existing: token",
                token = token,
                next = input.peek().map(Node::name),
            )
            .entered(),
            Parser::Choice(_) => tracing::span!(
                tracing::Level::INFO,
                "from_existing: choice",
                next = input.peek().map(Node::name),
            )
            .entered(),
            Parser::Seq(_) => tracing::span!(
                tracing::Level::INFO,
                "from_existing: seq",
                next = input.peek().map(Node::name),
            )
            .entered(),
            Parser::Rep(_) => tracing::span!(
                tracing::Level::INFO,
                "from_existing: rep",
                next = input.peek().map(Node::name),
            )
            .entered(),
            Parser::Named { name, .. } => tracing::span!(
                tracing::Level::INFO,
                "from_existing: named",
                name = name,
                next = input.peek().map(Node::name),
            )
            .entered(),
        };
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
                Some(_) => info!("Result: Ok"),
                None => info!("Result: Err"),
            };
            return result;
        }
        let result = match self {
            Parser::Just(_) | Parser::Named { .. } => input.next(),
            Parser::Choice(parsers) => {
                let next = input.peek()?;
                let parser = parsers.iter().find(|it| it.peak_edit(next)).unwrap();
                parser.from_existing(input)
            }
            Parser::Seq(parsers) => {
                let mut res = Vec::new();
                let mut len = 0;
                for p in parsers {
                    while let Some(Node::Unexpected(_)) = input.peek() {
                        warn!("Reusing unexpected");
                        let next = input.next().unwrap();
                        len += next.len();
                        res.push(next);
                    }
                    let part = p.from_existing(input).unwrap();
                    len += part.len();
                    if let Node::List { items, .. } = part {
                        res.extend(items);
                    } else {
                        res.push(part)
                    }
                }
                Some(Node::List { items: res, len })
            }
            Parser::Rep(parser) => {
                let mut res = vec![];
                let mut len = 0;
                while let Some(item) = parser.from_existing(input) {
                    len += item.len();
                    if let Node::List { items, .. } = item {
                        res.extend(items);
                    } else {
                        res.push(item)
                    }
                    while let Some(Node::Unexpected(_)) = input.peek() {
                        warn!("Reusing unexpected");
                        let next = input.next().unwrap();
                        len += next.len();
                        res.push(next);
                    }
                }
                Some(Node::List { items: res, len })
            }
        };

        match &result {
            Some(_) => info!("Result: Ok"),
            None => info!("Result: Err"),
        };
        result
    }

    pub fn edit<'a, 'i, 't, 's>(
        &'a self,
        mut offset: usize,
        node: Node<'a>,
        state: &mut State<'a, 't>,
        edit: &mut TokenEdit,
        changed: &mut Range<usize>,
    ) -> Res<'a> {
        let _span = match self {
            Parser::Just(token) => tracing::span!(
                tracing::Level::INFO,
                "edit: token",
                token = token,
                offset = offset,
                node = node.name(),
            )
            .entered(),
            Parser::Choice(_) => tracing::span!(
                tracing::Level::INFO,
                "edit: choice",
                offset = offset,
                node = node.name(),
            )
            .entered(),
            Parser::Seq(_) => tracing::span!(
                tracing::Level::INFO,
                "edit: seq",
                offset = offset,
                node = node.name(),
            )
            .entered(),
            Parser::Rep(_) => tracing::span!(
                tracing::Level::INFO,
                "edit: rep",
                offset = offset,
                node = node.name(),
            )
            .entered(),
            Parser::Named { name, .. } => tracing::span!(
                tracing::Level::INFO,
                "edit: named",
                name = name,
                offset = offset,
                node = node.name(),
            )
            .entered(),
        };
        if offset + node.len() < edit.remove.start || edit.remove.end <= offset {
            info!("Reusing {:?}", offset..offset + node.len());
            return Res::Ok(node);
        }
        if edit.remove.start <= offset {
            info!("Reparsing {:?}", offset..offset + node.len());
            return self.parse(offset, state).update_changed(offset, changed);
        }
        let result = match (self, node) {
            (Parser::Choice(parsers), node) => {
                let parser = parsers.iter().find(|it| it.peak_edit(&node)).unwrap();
                parser.edit(offset, node, state, edit, changed)
            }
            (Parser::Just(_), Node::Token(_)) => {
                self.parse(offset, state).update_changed(offset, changed)
            }
            (Parser::Seq(parsers), Node::List { items, len }) => {
                self.parse(offset, state).update_changed(offset, changed)
            }
            (Parser::Rep(parser), Node::List { items, .. }) => {
                let mut input = items.into_iter().peekable();
                let mut items = vec![];
                let mut next_existing_offset = 0;
                if let Some(first) = input.peek()
                    && parser.peak_edit(first)
                {
                    state.break_stack.push(parser);
                    while let Res::Ok(node) = parser.try_edit(
                        &mut offset,
                        &mut next_existing_offset,
                        &mut input,
                        &mut items,
                        state,
                        edit,
                        changed,
                    ) {
                        offset += node.len();
                        items.push(node);
                    }
                    state.break_stack.pop();
                    Res::Ok(Node::List {
                        len: items.iter().map(|it| it.len()).sum(),
                        items,
                    })
                } else {
                    self.parse(offset, state).update_changed(offset, changed)
                }
            }
            (Parser::Named { name, inner }, Node::Group { children, len, .. }) => {
                let child = inner
                    .from_existing(&mut children.into_iter().peekable())
                    .unwrap();
                let name = *name;
                inner.edit(offset, child, state, edit, changed).map(|it| {
                    let children = if let Node::List { items, .. } = it {
                        items
                    } else {
                        vec![it]
                    };
                    Node::Group {
                        kind: name,
                        children,
                        len,
                    }
                })
            }
            (_, _) => panic!("Unexpected parser/node combo"),
        };

        match &result {
            Res::Ok(_) => info!("Result: Ok"),
            Res::Err => info!("Result: Err"),
            Res::Break(idx) => info!("Result: Break({})", idx),
        };
        result
    }

    pub fn try_edit<'a, 'i, 't, 's, I: Iterator<Item = Node<'a>>>(
        &'a self,
        offset: &mut usize,
        next_existing_offset: &mut usize,
        input: &mut Peekable<I>,
        new: &mut Vec<Node<'a>>,
        state: &mut State<'a, 't>,
        edit: &mut TokenEdit,
        changed: &mut Range<usize>,
    ) -> Res<'a> {
        let _span = tracing::span!(tracing::Level::INFO, "try_edit", offset = offset,).entered();

        loop {
            let next_offset = if *offset > edit.remove.start {
                usize::try_from(isize::try_from(*next_existing_offset).unwrap() + edit.change())
                    .unwrap()
            } else {
                *next_existing_offset
            };
            let res = if *offset == next_offset
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
                            Res::Ok(_) => info!("Result: Ok"),
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
                    Res::Ok(_) => info!("Result: Ok"),
                    Res::Err => info!("Result: Err"),
                    Res::Break(idx) => info!("Result: Break({})", idx),
                };
                return res;
            } else if let Some(Node::Unexpected(n)) = new.last_mut() {
                *n += 1;
                *offset += 1;
            } else {
                *offset += 1;
                new.push(Node::Unexpected(1));
            }
        }
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
            Parser::Seq(parsers) => {
                if let Node::List { items, .. } = node {
                    items
                        .first()
                        .is_some_and(|first| parsers.first().unwrap().peak_edit(first))
                } else {
                    parsers.first().unwrap().peak_edit(node)
                }
            }
            Parser::Rep(parser) => {
                if let Node::List { items, .. } = node {
                    items.first().is_some_and(|first| parser.peak_edit(first))
                } else {
                    parser.peak_edit(node)
                }
            }
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
