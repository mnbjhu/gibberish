use async_lsp::lsp_types::request::Completion;
use async_lsp::lsp_types::{
    CompletionItem, CompletionItemKind, CompletionParams, CompletionResponse, Position, Range, Url,
};
use gibberish_core::err::Expected;
use gibberish_core::lang::CompiledLang;
use gibberish_core::node::Node;

pub mod capabilities;
pub mod diags;
pub mod document_symbols;
pub mod semantic_tokens;

use std::ops::ControlFlow;
use std::path::Path;
use std::sync::Arc;
use std::time::Duration;

use async_lsp::ClientSocket;
use async_lsp::client_monitor::ClientProcessMonitorLayer;
use async_lsp::concurrency::ConcurrencyLayer;
use async_lsp::lsp_types::{
    DidChangeTextDocumentParams, DidOpenTextDocumentParams, InitializeParams, notification, request,
};
use async_lsp::panic::CatchUnwindLayer;
use async_lsp::router::Router;
use async_lsp::server::LifecycleLayer;
use async_lsp::tracing::TracingLayer;
use dashmap::DashMap;
use futures::FutureExt;
use std::future::Future;
use tower::ServiceBuilder;
use tracing::Level;

use crate::api::ptr::{ParserCache, ParserIndex};
use crate::dsl::lexer::RuntimeLang;
use crate::lsp::capabilities::capabilities;
use crate::lsp::document_symbols::get_document_symbols;
use crate::lsp::semantic_tokens::{SemanticToken, get_semantic_tokens};

pub struct ServerState {
    pub client: ClientSocket,
    counter: i32,
    pub db: Arc<DashMap<String, String>>,
    pub parser: CompiledLang,
}

struct TickEvent;

pub async fn main_loop(parser_path: &Path) {
    let (server, _) = async_lsp::MainLoop::new_server(|client| {
        tokio::spawn({
            let client = client.clone();
            async move {
                let mut interval = tokio::time::interval(Duration::from_secs(1));
                loop {
                    interval.tick().await;
                    if client.emit(TickEvent).is_err() {
                        break;
                    }
                }
            }
        });
        let db = Arc::new(DashMap::new());

        let parser = CompiledLang::load(parser_path);

        let mut router = Router::new(ServerState {
            client: client.clone(),
            counter: 0,
            db,
            parser,
        });
        router
            .request::<request::Initialize, _>(|_, _| async { Ok(capabilities()) })
            .request::<request::SemanticTokensFullRequest, _>(|st, msg| {
                let db = st.db.clone(); // move Arc<DashMap<...>>
                let uri = msg.text_document.uri.clone(); // move params
                let parser = st.parser.clone();
                async move { semantic_tokens_full(db, uri, parser) }
            })
            .request::<request::Completion, _>(|st, msg| {
                let db = st.db.clone();
                let parser = st.parser.clone();
                let text = db
                    .get(&msg.text_document_position.text_document.uri.to_string())
                    .unwrap();
                let ast = parser.parse(text.value(), &st.cache);
                let offset = position_to_offset(msg.text_document_position.position, &text);
                if let Some(Node::Err(err)) = ast.at_offset(offset) {
                    err.expected().iter().filter_map(|it| {
                        if let Expected::Token(t) = it
                            && st
                                .cache
                                .lang
                                .lexer
                                .keywords
                                .iter()
                                .any(|kw| *kw == *t as usize)
                        {
                            Some(CompletionItem {
                                label: st.cache.lang.token_name(t),
                                kind: Some(CompletionItemKind::KEYWORD),
                                ..Default::default()
                            })
                        } else {
                            None
                        }
                    });
                }
                async { Ok(Some(CompletionResponse::Array(vec![]))) }
            })
            // .request::<request::SemanticTokensFullRequest, _>(semantic_tokens_full)
            .request::<request::DocumentSymbolRequest, _>(get_document_symbols)
            .notification::<notification::Initialized>(|_, _| ControlFlow::Continue(()))
            .notification::<notification::DidChangeConfiguration>(|_, _| ControlFlow::Continue(()))
            .notification::<notification::DidOpenTextDocument>(did_open)
            .notification::<notification::DidChangeTextDocument>(did_change)
            .notification::<notification::DidCloseTextDocument>(|_, _| ControlFlow::Continue(()))
            .notification::<notification::DidSaveTextDocument>(|_, _| ControlFlow::Continue(()))
            .event::<TickEvent>(|st, _| {
                st.counter += 1;
                ControlFlow::Continue(())
            });

        ServiceBuilder::new()
            .layer(TracingLayer::default())
            .layer(LifecycleLayer::default())
            .layer(CatchUnwindLayer::default())
            .layer(ConcurrencyLayer::default())
            .layer(ClientProcessMonitorLayer::new(client))
            .service(router)
    });

    // Prefer truly asynchronous piped stdin/stdout without blocking tasks.
    #[cfg(unix)]
    let (stdin, stdout) = (
        async_lsp::stdio::PipeStdin::lock_tokio().unwrap(),
        async_lsp::stdio::PipeStdout::lock_tokio().unwrap(),
    );
    // Fallback to spawn blocking read/write otherwise.
    #[cfg(not(unix))]
    let (stdin, stdout) = (
        tokio_util::compat::TokioAsyncReadCompatExt::compat(tokio::io::stdin()),
        tokio_util::compat::TokioAsyncWriteCompatExt::compat_write(tokio::io::stdout()),
    );

    server.run_buffered(stdin, stdout).await.unwrap();
}

#[allow(clippy::needless_pass_by_value)]
fn did_change(
    st: &mut ServerState,
    msg: DidChangeTextDocumentParams,
) -> ControlFlow<Result<(), async_lsp::Error>> {
    let path = msg.text_document.uri.clone().to_file_path().unwrap();
    st.db.insert(
        path.to_str().unwrap().to_string(),
        msg.content_changes[0].text.clone(),
    );
    st.publish_diags(msg.text_document.uri);
    ControlFlow::Continue(())
}

#[allow(clippy::needless_pass_by_value)]
fn did_open(
    st: &mut ServerState,
    msg: DidOpenTextDocumentParams,
) -> ControlFlow<Result<(), async_lsp::Error>> {
    let path = msg.text_document.uri.clone().to_file_path().unwrap();
    st.db
        .insert(path.to_str().unwrap().to_string(), msg.text_document.text);
    st.publish_diags(msg.text_document.uri);
    ControlFlow::Continue(())
}

#[allow(clippy::needless_pass_by_value)]
fn initialize(
    _: &mut ServerState,
    _: InitializeParams,
) -> impl Future<Output = Result<async_lsp::lsp_types::InitializeResult, async_lsp::ResponseError>>
{
    async move { Ok(capabilities::capabilities()) }
}

fn semantic_tokens_full(
    db: Arc<DashMap<String, String>>,
    uri: Url,
    parser: CompiledLang,
) -> Result<Option<async_lsp::lsp_types::SemanticTokensResult>, async_lsp::ResponseError> {
    let path = uri.clone().to_file_path().unwrap();
    let text: String = db
        .clone()
        .get(path.to_str().unwrap())
        .map(|v| v.clone())
        .unwrap_or_default();

    let ast = parser.clone().parse(&text, &cache);
    let mut tokens = vec![];
    for h in &cache.highlights {
        ast.query_all(h, &mut tokens);
    }
    let mut tokens = tokens
        .iter()
        .map(|(node, kind)| SemanticToken {
            span: node.span(),
            kind: *kind,
        })
        .collect::<Vec<_>>();
    tokens.sort_by(|first, second| first.span.start.cmp(&second.span.start));
    Ok(Some(async_lsp::lsp_types::SemanticTokensResult::Tokens(
        get_semantic_tokens(tokens, &text).unwrap_or_default(),
    )))
}

#[must_use]
pub fn offset_to_position_str(offset: usize, txt: &str) -> Position {
    let mut line: u32 = 0;
    let mut column: u32 = 0;
    for (i, c) in txt.chars().enumerate() {
        if i == offset {
            break;
        }
        if c == '\n' {
            line += 1;
            column = 0;
        } else {
            column += 1;
        }
    }
    Position::new(line, column)
}

#[must_use]
pub fn span_to_range_str(span: std::ops::Range<usize>, txt: &str) -> Range {
    let start_position = offset_to_position_str(span.start, txt);
    let end_position = offset_to_position_str(span.end, txt);
    Range::new(start_position, end_position)
}

#[allow(dead_code)]
#[must_use]
pub fn position_to_offset(position: Position, txt: &str) -> usize {
    let mut offset = 0;
    let mut line = 0;
    let mut column = 0;
    for c in txt.chars() {
        if line == position.line && column == position.character {
            break;
        }
        if c == '\n' {
            line += 1;
            column = 0;
        } else {
            column += 1;
        }
        offset += 1;
    }
    offset
}
