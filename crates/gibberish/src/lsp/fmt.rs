use pretty::BoxAllocator;
use tower_lsp::{
    jsonrpc,
    lsp_types::{DiagnosticSeverity, DocumentFormattingParams, Position, Range, TextEdit},
};

use crate::{
    ast::{CheckState, RootAst},
    lsp::{Backend, offset_to_position},
};
use tower_lsp::jsonrpc::Result;

pub async fn formatting(
    backend: &Backend,
    params: DocumentFormattingParams,
) -> Result<Option<Vec<TextEdit>>> {
    let uri = params.text_document.uri;
    let rope = backend
        .document_map
        .get(uri.as_str())
        .ok_or(jsonrpc::Error::new(jsonrpc::ErrorCode::InternalError))?;
    let ast = backend
        .ast_map
        .get(uri.as_str())
        .ok_or(jsonrpc::Error::new(jsonrpc::ErrorCode::InternalError))?;

    let root = RootAst(ast.as_group());
    let mut state = CheckState::default();
    root.check(&mut state);
    if state
        .errors
        .iter()
        .any(|it| it.severity() == DiagnosticSeverity::ERROR)
    {
        return Ok(None);
    }
    let arena = pretty::Arena::<()>::new();
    let new_text = root.pretty::<_, ()>(&arena).pretty(80).to_string();
    let range = Range {
        start: Position::new(0, 0),
        end: offset_to_position(rope.len_chars(), &rope).unwrap(),
    };
    Ok(Some(vec![TextEdit { range, new_text }]))
}
