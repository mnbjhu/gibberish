use async_lsp::lsp_types::{
    DocumentSymbol, DocumentSymbolParams, DocumentSymbolResponse, SymbolKind,
};
use futures::{FutureExt as _, future::BoxFuture};

use crate::{
    cli::lsp::ServerState,
    giblang::{lang::GLang, parser::g_parser},
    lsp::span_to_range_str,
    parser::node::{Group, Node},
};

impl Group<GLang> {
    pub fn symbols(&self, txt: &str) -> Vec<DocumentSymbol> {
        let mut ret = vec![];
        for child in &self.children {
            let span = child.span();
            let Node::Group(group) = child else {
                continue;
            };
            let range = span_to_range_str(span.clone(), txt);
            let s = DocumentSymbol {
                name: group.kind.to_string(),
                detail: None,
                kind: SymbolKind::NULL,
                tags: None,
                deprecated: None,
                range,
                selection_range: range,
                children: Some(group.symbols(txt)),
            };
            ret.push(s);
        }
        ret
    }
}

pub fn get_document_symbols(
    st: &mut ServerState,
    msg: DocumentSymbolParams,
) -> BoxFuture<'static, Result<Option<DocumentSymbolResponse>, async_lsp::ResponseError>> {
    let db = st.db.clone(); // move Arc<DashMap<...>>
    let uri = msg.text_document.uri; // move params

    async move {
        let path = uri.to_file_path().unwrap();

        // OWN the value; drop the DashMap Ref immediately.
        let text: String = db
            .get(path.to_str().unwrap())
            .map(|v| v.clone()) // clone String out of the Ref
            .unwrap_or_default();

        let ast = g_parser().parse(&text);
        Ok(Some(DocumentSymbolResponse::Nested(
            ast.as_group().symbols(&text),
        )))
    }
    .boxed() // -> BoxFuture<'static, _> (Send if inner is Send)
}
