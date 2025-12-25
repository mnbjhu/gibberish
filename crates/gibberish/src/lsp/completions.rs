use crate::lsp::definition::node_at_pos;
use crate::lsp::{Backend, position_to_offset};
use gibberish_core::err::Expected;
use gibberish_gibberish_parser::{Gibberish, GibberishLabel};
use tower_lsp::jsonrpc::Result;
use tower_lsp::lsp_types::{
    CompletionItem, CompletionItemKind, CompletionParams, CompletionResponse, InsertTextFormat,
    MessageType,
};

pub async fn completion(
    backend: &Backend,
    params: CompletionParams,
) -> Result<Option<CompletionResponse>> {
    let uri = params.text_document_position.text_document.uri;
    let rope = backend.document_map.get(uri.as_str()).unwrap();
    let position = params.text_document_position.position;
    let ast = backend.ast_map.get(uri.as_str()).unwrap();
    let mut completions = if let Some((node, state)) = node_at_pos(&rope, &ast, position) {
        node.completions(&state)
    } else {
        vec![]
    };
    let offset = position_to_offset(position, &rope).unwrap();
    completions.extend(
        ast.as_group()
            .completions_at(offset)
            .iter()
            .flat_map(|it| completions_from_expected(it).into_iter()),
    );
    Ok(Some(CompletionResponse::Array(completions)))
}

fn completions_from_expected(expected: &Expected<Gibberish>) -> Vec<CompletionItem> {
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
            _ => {}
        },
    }
    vec![]
}
