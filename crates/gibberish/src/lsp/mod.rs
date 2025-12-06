use async_lsp::lsp_types::{
    Position, Range
};
use gibberish_core::lang::CompiledLang;

pub mod capabilities;
pub mod diags;
pub mod document_symbols;
pub mod semantic_tokens;

use std::ops::ControlFlow;
use std::path::Path;
use std::sync::{Arc, Mutex};
use std::time::Duration;

use async_lsp::ClientSocket;
use async_lsp::client_monitor::ClientProcessMonitorLayer;
use async_lsp::concurrency::ConcurrencyLayer;
use async_lsp::lsp_types::{
    DidChangeTextDocumentParams, DidOpenTextDocumentParams, notification, request,
};
use async_lsp::panic::CatchUnwindLayer;
use async_lsp::router::Router;
use async_lsp::server::LifecycleLayer;
use async_lsp::tracing::TracingLayer;
use dashmap::DashMap;
use tower::ServiceBuilder;

use crate::lsp::capabilities::capabilities;
use crate::lsp::document_symbols::get_document_symbols;

pub struct ServerState {
    pub client: ClientSocket,
    counter: i32,
    pub db: Arc<DashMap<String, String>>,
    pub parser: Arc<Mutex<CompiledLang>>,
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
            parser: Arc::new(Mutex::new(parser)),
        });
        router
            .request::<request::Initialize, _>(|_, _| async { Ok(capabilities()) })
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
