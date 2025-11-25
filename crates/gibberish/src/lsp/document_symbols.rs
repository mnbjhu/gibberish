use crate::lsp::ServerState;
use crate::{dsl::lexer::RuntimeLang, lsp::span_to_range_str};
use async_lsp::lsp_types::{
    DocumentSymbol, DocumentSymbolParams, DocumentSymbolResponse, SymbolKind,
};
use futures::{FutureExt as _, future::BoxFuture};
use gibberish_tree::{
    lang::CompiledLang,
    node::{Group, Node},
};

pub fn symbols(group: Group<CompiledLang>, txt: &str, lang: &RuntimeLang) -> Vec<DocumentSymbol> {
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
            children: Some(group.symbols(txt, lang)),
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
    let cache = st.cache.clone();

    async move {
        let path = uri.to_file_path().unwrap();

        // OWN the value; drop the DashMap Ref immediately.
        let text: String = db
            .get(path.to_str().unwrap())
            .map(|v| v.clone()) // clone String out of the Ref
            .unwrap_or_default();

        let ast = parser.parse(&text, &cache);
        Ok(Some(DocumentSymbolResponse::Nested(
            ast.as_group().symbols(&text, &cache.lang),
        )))
    }
    .boxed() // -> BoxFuture<'static, _> (Send if inner is Send)
}
