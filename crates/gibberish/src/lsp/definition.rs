use gibberish_core::node::Node;
use gibberish_gibberish_parser::Gibberish;
use ropey::Rope;
use tower_lsp::jsonrpc::Result;
use tower_lsp::lsp_types::{
    GotoDefinitionParams, GotoDefinitionResponse, Location, Position, Range,
};

use crate::ast::{CheckState, LspItem as _, LspNode, RootAst};
use crate::lsp::{Backend, offset_to_position, position_to_offset};

pub async fn goto_definition(
    backend: &Backend,
    params: GotoDefinitionParams,
) -> Result<Option<GotoDefinitionResponse>> {
    let definition = || -> Option<GotoDefinitionResponse> {
        let uri = params.text_document_position_params.text_document.uri;
        let rope = backend.document_map.get(uri.as_str())?;
        let position = params.text_document_position_params.position;
        let ast = backend.ast_map.get(uri.as_str()).unwrap();

        let (node, state) = node_at_pos(&rope, &ast, position)?;
        let range = node.definition(&state)?;

        let start_position = offset_to_position(range.start, &rope)?;
        let end_position = offset_to_position(range.end, &rope)?;
        Some(GotoDefinitionResponse::Scalar(Location::new(
            uri,
            Range::new(start_position, end_position),
        )))
    }();
    Ok(definition)
}

pub fn node_at_pos<'a>(
    rope: &'a Rope,
    ast: &'a Node<Gibberish>,
    position: Position,
) -> Option<(LspNode<'a>, CheckState<'a>)> {
    let offset = position_to_offset(position, rope)?;
    let root = RootAst(ast.as_group());
    let mut state = CheckState::default();
    root.check(&mut state);
    let node = root.at(offset)?;
    Some((node, state))
}
