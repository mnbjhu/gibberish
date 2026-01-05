use lsp_types::{DocumentSymbol, Position, Range, SymbolKind};

use crate::runtime::{
    LexerParserState,
    lexer::{pos::Pos, token::Tok},
    parser::{node::Node, res::Res},
};

impl<'a> LexerParserState<'a> {
    pub fn document_symbols(&self) -> DocumentSymbol {
        if let Res::Ok(node) = &self.node
            && let Some(doc) = node.document_symbols(&mut 0, &mut Pos::zero(), self)
        {
            doc
        } else {
            let pos = Pos::zero().to_lsp_pos();
            let range = Range {
                start: pos,
                end: pos,
            };
            DocumentSymbol {
                name: "file".to_string(),
                detail: None,
                kind: SymbolKind::FILE,
                tags: None,
                deprecated: None,
                range,
                selection_range: range,
                children: Some(vec![]),
            }
        }
    }
}

impl Pos {
    pub fn to_lsp_pos(self) -> Position {
        Position {
            line: self.line as u32,
            character: self.char as u32,
        }
    }
}

impl Tok {
    fn document_symbol(
        &self,
        index: &mut usize,
        pos: &mut Pos,
        state: &LexerParserState,
    ) -> DocumentSymbol {
        let start = pos.to_lsp_pos();
        *pos += self.relative_pos;
        *index += 1;
        let end = pos.to_lsp_pos();
        let range = Range { start, end };
        DocumentSymbol {
            name: state.lexer.name_by_id(self.kind).to_string(),
            detail: None,
            kind: SymbolKind::FIELD,
            tags: None,
            deprecated: None,
            range,
            selection_range: range,
            children: None,
        }
    }
}

impl<'a> Node<'a> {
    fn document_symbols(
        &self,
        index: &mut usize,
        pos: &mut Pos,
        state: &LexerParserState,
    ) -> Option<DocumentSymbol> {
        match self {
            Node::Unexpected(len) => {
                let start = pos.to_lsp_pos();
                let mut children = vec![];
                for t in &state.lexer_state.tokens[*index..*index + len] {
                    children.push(t.document_symbol(index, pos, state))
                }
                let range = Range {
                    start,
                    end: pos.to_lsp_pos(),
                };
                Some(DocumentSymbol {
                    name: "Unexpected".to_string(),
                    detail: None,
                    kind: SymbolKind::NULL,
                    tags: None,
                    deprecated: None,
                    range,
                    selection_range: range,
                    children: Some(children),
                })
            }
            Node::Missing(p) => {
                let start = pos.to_lsp_pos();
                let range = Range { start, end: start };
                Some(DocumentSymbol {
                    name: format!(
                        "Missing: {}",
                        p.expected()
                            .iter()
                            .map(|it| it.get_str(state))
                            .collect::<Vec<_>>()
                            .join(", ")
                    ),
                    detail: None,
                    kind: SymbolKind::OPERATOR,
                    tags: None,
                    deprecated: None,
                    range,
                    selection_range: range,
                    children: None,
                })
            }
            Node::Token(_) => state
                .lexer_state
                .tokens
                .get(*index)
                .map(|it| it.document_symbol(index, pos, state)),
            Node::List { .. } => todo!(),
            Node::Group { kind, children, .. } => {
                let mut res = vec![];
                let start = pos.to_lsp_pos();
                for child in children {
                    if let Some(sym) = child.document_symbols(index, pos, state) {
                        res.push(sym);
                    }
                }
                let end = pos.to_lsp_pos();
                let range = Range { start, end };
                Some(DocumentSymbol {
                    name: state.name_by_id(*kind).to_string(),
                    detail: None,
                    kind: SymbolKind::STRUCT,
                    tags: None,
                    deprecated: None,
                    range,
                    selection_range: range,
                    children: Some(res),
                })
            }
        }
    }
}
