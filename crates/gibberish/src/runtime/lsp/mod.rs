use gibberish_gibberish_parser::Gibberish;
use lsp_types::{
    DidOpenTextDocumentParams, Hover, HoverContents, HoverParams, HoverProviderCapability,
    InitializeParams, InitializeResult, MarkedString, MessageType, OneOf, Position, Range,
    ServerCapabilities, TextDocumentSyncCapability, TextDocumentSyncKind, Uri,
    notification::{
        DidChangeTextDocument, DidOpenTextDocument, Exit, Initialized, Notification as _,
    },
    request::{HoverRequest, Initialize, Request as _, Shutdown},
};
use serde::{Deserialize, Serialize};
use serde_json::Value;
use std::{collections::HashMap, fs, path::Path};
use std::{
    io::{self, BufRead, Read, Write},
    path::PathBuf,
};

use crate::{
    ast::RootAst,
    runtime::{LexerParserState, build::RuntimeBuilder, lexer::Lexer, parser::Parser},
};

pub struct LspState {}

fn build_parser(path: &Path) -> RuntimeBuilder {
    let text = fs::read_to_string(path).unwrap();
    let lst = Gibberish::parse(&text);
    if lst.has_errors() {
        panic!("Errors in syntax");
    }
    let ast = RootAst(lst.as_group());
    let mut builder = RuntimeBuilder::default();
    ast.build_runtime(&mut builder);
    builder
}

pub fn start_lsp(path: &Path) {
    let builder = build_parser(path);
    let stdin = io::stdin();
    let mut stdin_lock = stdin.lock();
    let mut stdout = io::stdout();

    // Very small in-memory document store: URI -> full text
    let mut docs: HashMap<Uri, LexerParserState> = HashMap::new();

    // Main blocking message loop
    loop {
        let msg = match read_lsp_message(&mut stdin_lock) {
            Ok(Some(m)) => m,
            Ok(None) => break, // EOF
            Err(e) => {
                eprintln!("Failed to read message: {e}");
                break;
            }
        };

        // Parse JSON-RPC envelope
        let rpc: RpcMessage = match serde_json::from_str(&msg) {
            Ok(v) => v,
            Err(e) => {
                eprintln!("Invalid JSON: {e}\n{msg}");
                continue;
            }
        };

        // Notifications (no "id") vs requests (have "id")
        match (rpc.method.as_deref(), rpc.id.clone()) {
            // ----------------------
            // Requests
            // ----------------------
            (Some(m), Some(id)) if m == Initialize::METHOD => {
                let params: InitializeParams = rpc
                    .params
                    .as_ref()
                    .and_then(|v| serde_json::from_value(v.clone()).ok())
                    .unwrap_or_default();

                let result = InitializeResult {
                    capabilities: ServerCapabilities {
                        text_document_sync: Some(TextDocumentSyncCapability::Kind(
                            TextDocumentSyncKind::FULL,
                        )),
                        hover_provider: None,
                        ..Default::default()
                    },
                    server_info: None,
                };

                let resp = RpcResponse::result(id, serde_json::to_value(result).unwrap());
                write_lsp_response(&mut stdout, &resp).unwrap();

                // Optional: tell client we started (via window/logMessage)
                // (This is a notification from server to client)
                let _ = server_log(
                    &mut stdout,
                    MessageType::INFO,
                    format!(
                        "Initialized by client: {:?}",
                        params.client_info.as_ref().map(|c| &c.name)
                    ),
                );
            }

            (Some(m), Some(id)) if m == Shutdown::METHOD => {
                // Per spec, reply with null result.
                let resp = RpcResponse::result(id, Value::Null);
                write_lsp_response(&mut stdout, &resp).unwrap();
            }

            // Unknown request -> Method not found (-32601)
            (Some(m), Some(id)) => {
                let resp = RpcResponse::error(id, -32601, format!("Method not found: {m}"));
                write_lsp_response(&mut stdout, &resp).unwrap();
            }

            // ----------------------
            // Notifications
            // ----------------------
            (Some(m), None) if m == Initialized::METHOD => {
                // ignore
            }

            (Some(m), None) if m == DidOpenTextDocument::METHOD => {
                if let Some(params) = rpc.params.as_ref().and_then(|v| {
                    serde_json::from_value::<DidOpenTextDocumentParams>(v.clone()).ok()
                }) {
                    docs.insert(
                        params.text_document.uri,
                        LexerParserState::new(
                            params.text_document.text,
                            &builder.lexer,
                            &builder.parsers.get("root").expect("No root found"),
                        ),
                    );
                }
            }
            //
            // (Some(m), None) if m == DidChangeTextDocument::METHOD => {
            //     if let Some(params) = rpc.params.as_ref().and_then(|v| {
            //         serde_json::from_value::<DidChangeTextDocumentParams>(v.clone()).ok()
            //     }) {
            //         // FULL sync: client sends whole document in change[0].text
            //         if let Some(change) = params.content_changes.into_iter().next() {
            //             docs.insert(params.text_document.uri, change.text);
            //         }
            //     }
            // }
            (Some(m), None) if m == Exit::METHOD => {
                // If we already got shutdown, exit 0; otherwise 1.
                // Minimal: just exit 0.
                break;
            }

            // Unknown notification -> ignore
            _ => {}
        }
    }
}

#[derive(Debug, Deserialize)]
struct RpcMessage {
    #[serde(default)]
    jsonrpc: Option<String>,
    #[serde(default)]
    id: Option<Value>,
    #[serde(default)]
    method: Option<String>,
    #[serde(default)]
    params: Option<Value>,
}

#[derive(Debug, Serialize)]
struct RpcResponse {
    jsonrpc: &'static str,
    id: Value,
    #[serde(skip_serializing_if = "Option::is_none")]
    result: Option<Value>,
    #[serde(skip_serializing_if = "Option::is_none")]
    error: Option<RpcError>,
}

#[derive(Debug, Serialize)]
struct RpcError {
    code: i32,
    message: String,
}

impl RpcResponse {
    fn result(id: Value, result: Value) -> Self {
        Self {
            jsonrpc: "2.0",
            id,
            result: Some(result),
            error: None,
        }
    }
    fn error(id: Value, code: i32, message: String) -> Self {
        Self {
            jsonrpc: "2.0",
            id,
            result: None,
            error: Some(RpcError { code, message }),
        }
    }
}

// -------------------------
// LSP message framing (stdio)
// -------------------------
// Reads: "Content-Length: N\r\n\r\n<json bytes...>"

fn read_lsp_message<R: BufRead>(r: &mut R) -> io::Result<Option<String>> {
    let mut content_length: Option<usize> = None;

    // Read headers
    loop {
        let mut line = String::new();
        let n = r.read_line(&mut line)?;
        if n == 0 {
            // EOF
            return Ok(None);
        }

        let line_trim = line.trim_end_matches(&['\r', '\n'][..]);
        if line_trim.is_empty() {
            break; // end of headers
        }

        let lower = line_trim.to_ascii_lowercase();
        if let Some(rest) = lower.strip_prefix("content-length:") {
            let v = rest.trim().parse::<usize>().ok();
            content_length = v;
        }
    }

    let len = match content_length {
        Some(v) => v,
        None => {
            return Err(io::Error::new(
                io::ErrorKind::InvalidData,
                "Missing Content-Length",
            ));
        }
    };

    // Read exactly len bytes
    let mut buf = vec![0u8; len];
    r.read_exact(&mut buf)?;
    let s = String::from_utf8(buf)
        .map_err(|_| io::Error::new(io::ErrorKind::InvalidData, "Invalid UTF-8 in body"))?;
    Ok(Some(s))
}

fn write_lsp_response<W: Write>(w: &mut W, resp: &RpcResponse) -> io::Result<()> {
    let body = serde_json::to_vec(resp)
        .map_err(|e| io::Error::new(io::ErrorKind::InvalidData, e.to_string()))?;
    write!(w, "Content-Length: {}\r\n\r\n", body.len())?;
    w.write_all(&body)?;
    w.flush()?;
    Ok(())
}

fn server_log<W: Write>(w: &mut W, typ: MessageType, message: String) -> io::Result<()> {
    // window/logMessage notification
    #[derive(Serialize)]
    struct LogParams {
        #[serde(rename = "type")]
        typ: MessageType,
        message: String,
    }
    #[derive(Serialize)]
    struct Notif<'a> {
        jsonrpc: &'static str,
        method: &'a str,
        params: LogParams,
    }

    let notif = Notif {
        jsonrpc: "2.0",
        method: "window/logMessage",
        params: LogParams { typ, message },
    };

    let body = serde_json::to_vec(&notif)
        .map_err(|e| io::Error::new(io::ErrorKind::InvalidData, e.to_string()))?;
    write!(w, "Content-Length: {}\r\n\r\n", body.len())?;
    w.write_all(&body)?;
    w.flush()?;
    Ok(())
}
