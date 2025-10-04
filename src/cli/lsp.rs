use std::ops::ControlFlow;
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
use tower::ServiceBuilder;
use tracing::Level;

use crate::giblang::parser::g_parser;
use crate::lsp::capabilities;
use crate::lsp::document_symbols::get_document_symbols;
use crate::lsp::semantic_tokens::{get_semantic_tokens, semantic_token_map};

pub struct ServerState {
    pub client: ClientSocket,
    counter: i32,
    pub db: Arc<DashMap<String, String>>,
}

struct TickEvent;

pub async fn main_loop() {
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

        let mut router = Router::new(ServerState {
            client: client.clone(),
            counter: 0,
            db,
        });
        router
            .request::<request::Initialize, _>(initialize)
            // .request::<request::Completion, _>(|st, msg| {
            // })
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

    tracing_subscriber::fmt()
        .with_max_level(Level::ERROR)
        .with_ansi(false)
        .with_writer(std::io::stderr)
        .init();

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

use futures::future::{self, BoxFuture, Ready};

#[allow(clippy::needless_pass_by_value)]
fn initialize(
    _: &mut ServerState,
    _: InitializeParams,
) -> Ready<Result<async_lsp::lsp_types::InitializeResult, async_lsp::ResponseError>> {
    // Ready<T> is 'static if T is 'static, and it's Send if T: Send.
    future::ready(Ok(capabilities::capabilities()))
}

fn semantic_tokens_full(
    st: &mut ServerState,
    msg: async_lsp::lsp_types::SemanticTokensParams,
) -> BoxFuture<
    'static,
    Result<Option<async_lsp::lsp_types::SemanticTokensResult>, async_lsp::ResponseError>,
> {
    let db = st.db.clone(); // move Arc<DashMap<...>>
    let uri = msg.text_document.uri; // move params
    async move {
        let path = uri.to_file_path().unwrap();

        let text: String = db
            .get(path.to_str().unwrap())
            .map(|v| v.clone())
            .unwrap_or_default();

        let ast = g_parser().parse(&text);
        let mut tokens = vec![];
        ast.tokens(&semantic_token_map(), &mut tokens);
        Ok(Some(async_lsp::lsp_types::SemanticTokensResult::Tokens(
            get_semantic_tokens(tokens, &text).unwrap_or_default(),
        )))
    }
    .boxed()
}
