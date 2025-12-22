use crate::lsp::{Backend, position_to_offset};
use gibberish_gibberish_parser::Gibberish;
use tower_lsp::jsonrpc::Result;
use tower_lsp::lsp_types::{
    CompletionItem, CompletionItemKind, CompletionParams, CompletionResponse,
};

pub async fn completion(
    backend: &Backend,
    params: CompletionParams,
) -> Result<Option<CompletionResponse>> {
    let completions = || -> Option<CompletionResponse> {
        let uri = params.text_document_position.text_document.uri;
        let rope = backend.document_map.get(uri.as_str())?;
        let position = params.text_document_position.position;
        let offset = position_to_offset(position, &rope)?;
        let ast = backend.ast_map.get(uri.as_str()).unwrap();
        let completions = ast.as_group().completions_at(offset);
        Some(CompletionResponse::Array(
            completions
                .iter()
                .map(|it| {
                    let mut completion = CompletionItem::new_simple(
                        "completion".to_string(),
                        it.debug_name(&Gibberish),
                    );
                    completion.kind = Some(CompletionItemKind::SNIPPET);
                    completion
                })
                .collect(),
        ))
    }();
    Ok(completions)
}
