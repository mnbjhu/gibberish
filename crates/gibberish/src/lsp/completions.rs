use crate::ast::CheckState;
use crate::lsp::definition::node_at_pos;
use crate::lsp::{Backend, position_to_offset};
use gibberish_core::err::Expected;
use gibberish_gibberish_parser::{Gibberish, GibberishLabel};
use tower_lsp::jsonrpc::Result;
use tower_lsp::lsp_types::{
    CompletionItem, CompletionItemKind, CompletionParams, CompletionResponse, InsertTextFormat,
};

pub async fn completion(
    backend: &Backend,
    params: CompletionParams,
) -> Result<Option<CompletionResponse>> {
    let uri = params.text_document_position.text_document.uri;
    let rope = backend.document_map.get(uri.as_str()).unwrap();
    let position = params.text_document_position.position;
    let ast = backend.ast_map.get(uri.as_str()).unwrap();
    let (node, state) = node_at_pos(&rope, &ast, position);
    let mut completions = vec![];
    if let Some(node) = node {
        let from_missing = node.completions(&state);
        completions.extend(from_missing);
    }
    let offset = position_to_offset(position, &rope).unwrap();
    let root = ast.as_group();
    let from_current_node = root
        .completions_at(offset)
        .into_iter()
        .flat_map(|it| completions_from_expected(&it, &state).into_iter());
    completions.extend(from_current_node);

    Ok(Some(CompletionResponse::Array(completions)))
}

fn completions_from_expected(
    expected: &Expected<Gibberish>,
    state: &CheckState<'_>,
) -> Vec<CompletionItem> {
    match expected {
        Expected::Token(_) => {}
        Expected::Group(_) => {}
        Expected::Label(label) => match label {
            GibberishLabel::Declaration => {
                return vec![
                    CompletionItem {
                        label: "parser".to_string(),
                        kind: Some(CompletionItemKind::SNIPPET),
                        insert_text: Some("parser ${1:name} = ${2:expr};".to_string()),
                        insert_text_format: Some(InsertTextFormat::SNIPPET),
                        ..Default::default()
                    },
                    CompletionItem {
                        label: "parser".to_string(),
                        kind: Some(CompletionItemKind::KEYWORD),
                        ..Default::default()
                    },
                    CompletionItem {
                        label: "token".to_string(),
                        kind: Some(CompletionItemKind::KEYWORD),
                        ..Default::default()
                    },
                    CompletionItem {
                        label: "keyword".to_string(),
                        kind: Some(CompletionItemKind::KEYWORD),
                        ..Default::default()
                    },
                ];
            }
            GibberishLabel::Expression => {
                return state
                    .defs
                    .iter()
                    .map(|(name, _)| CompletionItem {
                        label: name.to_string(),
                        kind: Some(CompletionItemKind::VARIABLE),
                        ..Default::default()
                    })
                    .collect();
            }
            _ => {}
        },
    }
    vec![]
}
