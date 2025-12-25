use crate::lsp::Backend;
use crate::lsp::definition::node_at_pos;
use tower_lsp::jsonrpc::Result;
use tower_lsp::lsp_types::{Hover, HoverParams};

pub async fn hover(backend: &Backend, params: HoverParams) -> Result<Option<Hover>> {
    let hover = || -> Option<Hover> {
        let uri = params.text_document_position_params.text_document.uri;
        let rope = backend.document_map.get(uri.as_str())?;
        let position = params.text_document_position_params.position;
        let ast = backend.ast_map.get(uri.as_str()).unwrap();
        let (node, state) = node_at_pos(&rope, &ast, position);

        node?.hover(&state).map(|contents| Hover {
            contents,
            range: None,
        })
    }();
    Ok(hover)
}
