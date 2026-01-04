use std::{fmt::Display, ops::Range, ptr};

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Token {
    Ident,
    Colon,
    Num,
    Semi,
}

#[derive(Debug)]
pub enum Parser {
    Just(Token),
    Choice(Vec<Parser>),
    Seq(Vec<Parser>),
    Rep(Box<Parser>),
}

pub struct State<'a> {
    tokens: Vec<Token>,
    break_stack: Vec<&'a Parser>,
}

impl<'a> State<'a> {
    pub fn new(tokens: Vec<Token>) -> Self {
        Self {
            tokens,
            break_stack: vec![],
        }
    }

    pub fn edit(&mut self, edit: TokenEdit) -> Edit {
        for _ in 0..edit.remove.len() {
            self.tokens.remove(edit.remove.start);
        }
        let len = edit.insert.len();
        for token in edit.insert.into_iter().rev() {
            self.tokens.insert(edit.remove.start, token);
        }
        Edit {
            remove: edit.remove,
            insert: len,
        }
    }

    pub fn token_at(&self, offset: usize) -> Option<Token> {
        self.tokens.get(offset).copied()
    }

    pub fn get_break(&self, offset: usize) -> Option<usize> {
        self.break_stack
            .iter()
            .enumerate()
            .rev()
            .find_map(|(index, it)| {
                if it.peak(offset, self) {
                    Some(index)
                } else {
                    None
                }
            })
    }
}

#[derive(Debug)]
pub enum Res<'a> {
    Ok(Node<'a>),
    Break(usize),
    Err,
}

impl<'a> Res<'a> {
    pub fn unwrap(self) -> Node<'a> {
        match self {
            Res::Ok(node) => node,
            Res::Break(index) => panic!("Expected Ok node but got Break({index})"),
            Res::Err => panic!("Expected Ok node but got Err"),
        }
    }
}

impl<'a> Parser {
    fn kind(&self) -> String {
        match self {
            Parser::Just(t) => format!("{t:?}"),
            Parser::Choice(_) => "choice".to_string(),
            Parser::Seq(_) => "seq".to_string(),
            Parser::Rep(_) => "rep".to_string(),
        }
    }

    fn parse(&'a self, mut offset: usize, state: &mut State<'a>) -> Res<'a> {
        println!("Parsing {kind} at {offset}", kind = self.kind());
        match self {
            Parser::Just(token) => {
                if let Some(current) = state.token_at(offset) {
                    if current == *token {
                        println!("Bump {token:?}");
                        Res::Ok(Node::Token(self))
                    } else if let Some(index) = state.get_break(offset) {
                        let b = index + 1;
                        println!("Hit break {b}: {}", state.break_stack[b - 1].kind());
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
                    Res::Ok(Node::Choice {
                        inner: Box::new(inner),
                        found_index: index,
                        options: self,
                    })
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
                Res::Ok(Node::Seq {
                    len: nodes.iter().map(|it| it.len()).sum(),
                    parts: nodes,
                    parser: self,
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
                loop {
                    let res = inner.try_parse(&mut offset, state, &mut items);
                    match res {
                        Res::Ok(node) => {
                            offset += node.len();
                            items.push(node);
                        }
                        _ => {
                            state.break_stack.pop();
                            return Res::Ok(Node::Rep {
                                len: items.iter().map(|it| it.len()).sum(),
                                items,
                                parser: self,
                            });
                        }
                    }
                }
            }
        }
    }

    fn try_parse(
        &'a self,
        offset: &mut usize,
        state: &mut State<'a>,
        nodes: &mut Vec<Node<'a>>,
    ) -> Res<'a> {
        let mut res = self.parse(*offset, state);
        while let Res::Err = res {
            if state.token_at(*offset).is_some() {
                println!(
                    "Bump err from try_parse {:?}",
                    state.token_at(*offset).unwrap()
                );
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

    fn try_edit(
        &'a self,
        offset: &mut usize,
        existing: &mut impl Iterator<Item = Node<'a>>,
        state: &mut State<'a>,
        nodes: &mut Vec<Node<'a>>,
        edit: &Edit,
        next_existing_offset: &mut usize,
    ) -> Res<'a> {
        loop {
            let next = if *offset >= *next_existing_offset {
                existing.next()
            } else {
                None
            };
            if let Some(next) = next.as_ref() {
                *next_existing_offset += next.len();
            }
            let res = if let Some(existing) = next
                && let Some(p) = existing.parser()
                && ptr::eq(p, self)
            {
                existing.edit(*offset, edit, state)
            } else {
                self.parse(*offset, state)
            };
            if let Res::Err = res {
                if state.token_at(*offset).is_some() {
                    println!(
                        "Bump err from try_edit {:?}",
                        state.token_at(*offset).unwrap()
                    );
                    *offset += 1;
                    if let Some(Node::Unexpected(len)) = nodes.last_mut() {
                        *len += 1;
                    } else {
                        nodes.push(Node::Unexpected(1));
                    }
                } else {
                    return Res::Break(0);
                }
            } else {
                return res;
            }
        }
    }

    fn peak(&self, offset: usize, state: &State<'a>) -> bool {
        match self {
            Parser::Just(token) => state.token_at(offset).is_some_and(|it| it == *token),
            Parser::Choice(parsers) => parsers.iter().any(|it| it.peak(offset, state)),
            Parser::Seq(parsers) => parsers.first().is_some_and(|it| it.peak(offset, state)),
            Parser::Rep(parser) => parser.peak(offset, state),
        }
    }
}

#[derive(Debug)]
pub enum Node<'a> {
    Unexpected(usize),
    Missing(&'a Parser),
    Token(&'a Parser),
    Choice {
        inner: Box<Node<'a>>,
        found_index: usize,
        options: &'a Parser,
    },
    Seq {
        parts: Vec<Node<'a>>,
        len: usize,
        parser: &'a Parser,
    },
    Rep {
        items: Vec<Node<'a>>,
        len: usize,
        parser: &'a Parser,
    },
    Unparsed {
        parser: &'a Parser,
        len: usize,
    },
}

impl<'a> Node<'a> {
    pub fn len(&self) -> usize {
        match self {
            Node::Unexpected(len) => *len,
            Node::Missing(_) => 0,
            Node::Token(_) => 1,
            Node::Choice { inner, .. } => inner.len(),
            Node::Seq { len, .. } => *len,
            Node::Unparsed { len, .. } => *len,
            Node::Rep { len, .. } => *len,
        }
    }

    #[must_use]
    pub fn is_empty(&self) -> bool {
        self.len() == 0
    }

    pub fn edit(self, mut offset: usize, edit: &Edit, state: &mut State<'a>) -> Res<'a> {
        let kind = self
            .parser()
            .map(|it| it.kind())
            .unwrap_or("unknown".to_string());
        println!("Editing {kind} at {offset}");
        if offset + self.len() <= edit.remove.start {
            println!("Before edit {kind}");
            return Res::Ok(self);
        }
        if offset > edit.remove.end || offset == edit.remove.start {
            println!("Full reparse {kind}");
            return self.parser().unwrap().parse(offset, state);
        }
        match self {
            Node::Rep { items, parser, .. } => {
                let Parser::Rep(inner) = parser else { panic!() };
                state.break_stack.push(inner);
                let break_index = state.break_stack.len();
                let change = edit.change();
                let mut new: Vec<Node<'a>> = Vec::new();
                let mut existing = items.into_iter();
                let mut next_existing_offset: usize = 0;

                loop {
                    if offset >= edit.remove.end {
                        let next_offset = usize::try_from(
                            isize::try_from(next_existing_offset).unwrap() + change,
                        )
                        .unwrap();
                        println!("Check cached: offset: {offset}, next: {next_offset}");
                        if offset == next_offset {
                            new.extend(existing);
                            break;
                        }
                    }
                    let res = inner.try_edit(
                        &mut offset,
                        &mut existing,
                        state,
                        &mut new,
                        edit,
                        &mut next_existing_offset,
                    );
                    if let Res::Ok(res) = res {
                        offset += res.len();
                        new.push(res);
                    } else if let Res::Break(i) = res
                        && i == break_index
                    {
                        continue;
                    } else {
                        break;
                    }
                }
                state.break_stack.pop();
                println!("Finish rep");
                Res::Ok(Node::Rep {
                    len: new.iter().map(|it| it.len()).sum(),
                    items: new,
                    parser,
                })
            }
            _ => self.parser().unwrap().parse(offset, state),
        }
    }

    pub fn parser(&self) -> Option<&'a Parser> {
        match self {
            Node::Unexpected(_) => None,
            Node::Missing(parser) => Some(parser),
            Node::Token(p) => Some(p),
            Node::Choice { options, .. } => Some(options),
            Node::Seq { parser, .. } => Some(parser),
            Node::Unparsed { parser, .. } => Some(parser),
            Node::Rep { parser, .. } => Some(parser),
        }
    }
}

fn write_indent(offset: usize, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
    for _ in 0..offset {
        write!(f, "  ")?
    }
    Ok(())
}

impl Display for Tree<'_, '_> {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        self.node.fmt_at(f, 0, 0, self.tokens)
    }
}

pub struct TokenEdit {
    pub remove: Range<usize>,
    pub insert: Vec<Token>,
}

pub struct Edit {
    pub remove: Range<usize>,
    pub insert: usize,
}

impl Edit {
    pub fn change(&self) -> isize {
        isize::try_from(self.insert).unwrap() + isize::try_from(self.remove.start).unwrap()
            - isize::try_from(self.remove.end).unwrap()
    }
}

impl Node<'_> {
    fn fmt_at(
        &self,
        f: &mut std::fmt::Formatter<'_>,
        indent: usize,
        mut offset: usize,
        tokens: &[Token],
    ) -> std::fmt::Result {
        write_indent(indent, f)?;
        match self {
            Node::Unexpected(len) => {
                writeln!(f, "unexpected")?;
                for tok in &tokens[offset..offset + *len] {
                    write_indent(indent + 1, f)?;
                    writeln!(f, "{tok:?}")?;
                }
                Ok(())
            }
            Node::Missing(e) => {
                writeln!(f, "missing: {e:?}")
            }
            Node::Token(parser) => {
                let Parser::Just(t) = parser else { panic!() };
                writeln!(f, "{t:?}")
            }
            Node::Choice {
                inner, found_index, ..
            } => {
                writeln!(f, "choice: {found_index}")?;
                inner.fmt_at(f, indent + 1, offset, tokens)
            }
            Node::Seq { parts, .. } => {
                writeln!(f, "seq")?;
                for part in parts {
                    part.fmt_at(f, indent + 1, offset, tokens)?;
                    offset += part.len();
                }
                Ok(())
            }
            Node::Unparsed { len, .. } => {
                writeln!(f, "unparsed")?;
                for t in &tokens[offset..offset + len] {
                    write_indent(indent + 1, f)?;
                    writeln!(f, "{t:?}")?;
                }
                Ok(())
            }
            Node::Rep { items, .. } => {
                writeln!(f, "rep")?;
                for item in items {
                    item.fmt_at(f, indent + 1, offset, tokens)?;
                    offset += item.len();
                }
                Ok(())
            }
        }
    }
}

pub struct Tree<'a, 'src> {
    node: Node<'a>,
    tokens: &'src [Token],
}

fn main() {
    let value = Parser::Choice(vec![Parser::Just(Token::Ident), Parser::Just(Token::Num)]);
    let p = Parser::Seq(vec![
        Parser::Just(Token::Ident),
        Parser::Just(Token::Colon),
        value,
        Parser::Just(Token::Semi),
    ]);
    let p = Parser::Rep(Box::new(p));
    let mut state = State::new(vec![
        Token::Ident,
        Token::Colon,
        Token::Num,
        Token::Semi,
        Token::Ident,
        Token::Colon,
        Token::Ident,
        Token::Semi,
    ]);

    let res = p.parse(0, &mut state);
    let node = res.unwrap();

    println!("=== Initial parse ===");
    let tree = Tree {
        node: node.clone_structure(),
        tokens: &state.tokens,
    };
    println!("{tree}");

    // Test edit
    let edit = TokenEdit {
        remove: 4..4,
        insert: vec![Token::Ident, Token::Colon, Token::Num, Token::Semi],
    };
    let edit = state.edit(edit);

    println!("\n=== After edit (inserted Ident;Semi at position 4) ===");
    let node = node.edit(0, &edit, &mut state).unwrap();
    let tree = Tree {
        node,
        tokens: &state.tokens,
    };
    println!("{tree}")
}

// Helper for demonstration
impl Node<'_> {
    fn clone_structure(&self) -> Node<'_> {
        match self {
            Node::Unexpected(len) => Node::Unexpected(*len),
            Node::Missing(p) => Node::Missing(p),
            Node::Token(p) => Node::Token(p),
            Node::Choice {
                inner,
                found_index,
                options,
            } => Node::Choice {
                inner: Box::new(inner.clone_structure()),
                found_index: *found_index,
                options,
            },
            Node::Seq { parts, len, parser } => Node::Seq {
                parts: parts.iter().map(|p| p.clone_structure()).collect(),
                len: *len,
                parser,
            },
            Node::Rep { items, len, parser } => Node::Rep {
                items: items.iter().map(|i| i.clone_structure()).collect(),
                len: *len,
                parser,
            },
            Node::Unparsed { parser, len } => Node::Unparsed { parser, len: *len },
        }
    }
}
