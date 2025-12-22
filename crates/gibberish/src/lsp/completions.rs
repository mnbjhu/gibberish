use crate::lsp::Backend;
use crate::lsp::definition::node_at_pos;
use tower_lsp::jsonrpc::Result;
use tower_lsp::lsp_types::{CompletionParams, CompletionResponse};

pub async fn completion(
    backend: &Backend,
    params: CompletionParams,
) -> Result<Option<CompletionResponse>> {
    let completions = || -> Option<CompletionResponse> {
        let uri = params.text_document_position.text_document.uri;
        let rope = backend.document_map.get(uri.as_str())?;
        let position = params.text_document_position.position;
        let ast = backend.ast_map.get(uri.as_str()).unwrap();
        // let offset = position_to_offset(position, &rope)?;
        // let completions = ast.as_group().completions_at(offset);
        let (node, state) = node_at_pos(&rope, &ast, position)?; // TODO: handle properly
        let completions = node.completions(&state);
        dbg!("Found completions {}", &completions);
        Some(CompletionResponse::Array(completions))
    }();
    Ok(completions)
}
