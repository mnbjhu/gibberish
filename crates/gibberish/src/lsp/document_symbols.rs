use crate::lsp::ServerState;
use crate::lsp::span_to_range_str;
use async_lsp::lsp_types::{
    DocumentSymbol, DocumentSymbolParams, DocumentSymbolResponse, SymbolKind,
};
use futures::{FutureExt as _, future::BoxFuture};
use gibberish_core::lang::CompiledLang;
use gibberish_core::lang::Lang;
use gibberish_core::node::Group;
use gibberish_core::node::Node;
use gibberish_dyn_lib::bindings::parse;

pub fn symbols(group: &Group<CompiledLang>, txt: &str, lang: &CompiledLang) -> Vec<DocumentSymbol> {
    let mut ret = vec![];
    for child in &group.children {
        let span = child.span();
        let Node::Group(group) = child else {
            continue;
        };
        let range = span_to_range_str(span.clone(), txt);
        let s = DocumentSymbol {
            name: lang.syntax_name(&group.kind),
            detail: None,
            kind: SymbolKind::NULL,
            tags: None,
            deprecated: None,
            range,
            selection_range: range,
            children: Some(symbols(group, txt, lang)),
        };
        ret.push(s);
    }
    ret
}

pub fn get_document_symbols(
    st: &mut ServerState,
    msg: DocumentSymbolParams,
) -> BoxFuture<'static, Result<Option<DocumentSymbolResponse>, async_lsp::ResponseError>> {
    let db = st.db.clone(); // move Arc<DashMap<...>>
    let uri = msg.text_document.uri; // move params
    let parser = st.parser.clone();

    async move {
        let path = uri.to_file_path().unwrap();

        // OWN the value; drop the DashMap Ref immediately.
        let text: String = db
            .get(path.to_str().unwrap())
            .map(|v| v.clone()) // clone String out of the Ref
            .unwrap_or_default();

        let ast = parse(&parser.lock().unwrap(), &text);
        Ok(Some(DocumentSymbolResponse::Nested(symbols(
            ast.as_group(),
            &text,
            &parser.lock().unwrap(),
        ))))
    }
    .boxed() // -> BoxFuture<'static, _> (Send if inner is Send)
}
