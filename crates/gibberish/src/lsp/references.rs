use crate::ast::{CheckState, LspItem as _, RootAst};
use crate::lsp::{Backend, offset_to_position, position_to_offset};
use tower_lsp::jsonrpc::Result;
use tower_lsp::lsp_types::{Location, Range, ReferenceParams};

pub async fn references(
    backend: &Backend,
    params: ReferenceParams,
) -> Result<Option<Vec<Location>>> {
    let reference_list = || -> Option<Vec<Location>> {
        let uri = params.text_document_position.text_document.uri;
        let rope = backend.document_map.get(uri.as_str())?;
        let position = params.text_document_position.position;
        let offset = position_to_offset(position, &rope)?;
        let ast = backend.ast_map.get(uri.as_str()).unwrap();

        let root = RootAst(ast.as_group());
        let mut state = CheckState::default();
        root.check(&mut state);

        let node = root.at(offset);
        let node = node?;
        let reference_span_list = node.references(&state);

        let ret = reference_span_list
            .into_iter()
            .filter_map(|range| {
                let start_position = offset_to_position(range.start, &rope)?;
                let end_position = offset_to_position(range.end, &rope)?;

                let range = Range::new(start_position, end_position);

                Some(Location::new(uri.clone(), range))
            })
            .collect::<Vec<_>>();
        Some(ret)
    }();
    Ok(reference_list)
}
