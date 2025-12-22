use crate::ast::{CheckState, LspItem as _, RootAst};
use crate::lsp::{Backend, position_to_offset};
use tower_lsp::jsonrpc::Result;
use tower_lsp::lsp_types::{Hover, HoverParams};

pub async fn hover(backend: &Backend, params: HoverParams) -> Result<Option<Hover>> {
    let hover = || -> Option<Hover> {
        let uri = params.text_document_position_params.text_document.uri;
        let rope = backend.document_map.get(uri.as_str())?;
        let position = params.text_document_position_params.position;
        let offset = position_to_offset(position, &rope)?;
        let ast = backend.ast_map.get(uri.as_str()).unwrap();
        let root = RootAst(ast.as_group());

        let node = root.at(offset)?;

        let mut state = CheckState::default();
        root.check(&mut state);

        node.hover(&state).map(|contents| Hover {
            contents,
            range: None,
        })
    }();
    Ok(hover)
}
