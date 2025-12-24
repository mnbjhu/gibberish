use crate::ast::{CheckState, RootAst};
use crate::lsp::definition::node_at_pos;
use crate::lsp::{Backend, position_to_offset};
use gibberish_core::err::Expected;
use gibberish_gibberish_parser::{Gibberish, GibberishLabel};
use tower_lsp::jsonrpc::Result;
use tower_lsp::lsp_types::{
    CompletionItem, CompletionItemKind, CompletionParams, CompletionResponse,
};

pub async fn completion(
    backend: &Backend,
    params: CompletionParams,
) -> Result<Option<CompletionResponse>> {
    let uri = params.text_document_position.text_document.uri;
    let rope = backend.document_map.get(uri.as_str()).unwrap();
    let position = params.text_document_position.position;
    let ast = backend.ast_map.get(uri.as_str()).unwrap();
    let completions = if let Some((node, state)) = node_at_pos(&rope, &ast, position) {
        node.completions(&state)
    } else {
        vec![]
    };
    let completions = if completions.is_empty() {
        let mut state = CheckState::default();
        let root = RootAst(ast.as_group());
        root.check(&mut state);
        let offset = position_to_offset(position, &rope).unwrap();
        let completions = ast.as_group().completions_at(offset);
        completions
            .iter()
            .flat_map(|it| completions_from_expected(it, &state).into_iter())
            .collect()
    } else {
        completions
    };
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
                return vec![CompletionItem {
                    label: "parser".to_string(),
                    kind: Some(CompletionItemKind::KEYWORD),
                    ..Default::default()
                }];
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
