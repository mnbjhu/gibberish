use gibberish_gibberish_parser::Gibberish;
use lsp_types::{
    Diagnostic, DidChangeTextDocumentParams, DidOpenTextDocumentParams, DocumentSymbolResponse,
    MessageType, PublishDiagnosticsParams, Range, Uri,
    notification::{
        DidChangeTextDocument, DidOpenTextDocument, Exit, Initialized, Notification as _,
    },
    request::{DocumentSymbolRequest, Initialize, Request, SemanticTokensFullRequest, Shutdown},
};
use serde::{Deserialize, Serialize};
use serde_json::Value;
use std::io::{self, BufRead, Write};
use std::{collections::HashMap, fs, path::Path};
use tracing::debug;

use crate::{
    ast::RootAst,
    runtime::{
        LexerParserState,
        build::RuntimeBuilder,
        lexer::{edit::TextEdit, pos::Pos},
        lsp::semantic_tokens::semantic_tokens_structured,
    },
};

pub mod document_symbols;
pub mod semantic_tokens;

pub fn build_parser(text: &str) -> RuntimeBuilder {
    let lst = Gibberish::parse(text);
    if lst.has_errors() {
        panic!("Errors in syntax");
    }
    let ast = RootAst(lst.as_group());
    let mut builder = RuntimeBuilder::default();
    ast.build_runtime(&mut builder);
    builder
}

pub fn build_parser_from_file(path: &Path) -> RuntimeBuilder {
    let text = fs::read_to_string(path).unwrap();
    build_parser(&text)
}

pub fn start_lsp(path: &Path) {
    let builder = build_parser_from_file(path);
    let stdin = io::stdin();
    let mut stdin_lock = stdin.lock();
    let mut stdout = io::stdout();

    let mut docs: HashMap<Uri, LexerParserState> = HashMap::new();
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

                use lsp_types::*;

                let result = InitializeResult {
                    capabilities: ServerCapabilities {
                        text_document_sync: Some(TextDocumentSyncCapability::Kind(
                            TextDocumentSyncKind::INCREMENTAL,
                        )),
                        hover_provider: None,
                        document_symbol_provider: Some(OneOf::Left(true)),

                        semantic_tokens_provider: Some(
                            SemanticTokensServerCapabilities::SemanticTokensOptions(
                                SemanticTokensOptions {
                                    legend: SemanticTokensLegend {
                                        token_types: vec![
                                            SemanticTokenType::KEYWORD,
                                            SemanticTokenType::STRING,
                                            SemanticTokenType::NUMBER,
                                            SemanticTokenType::COMMENT,
                                            SemanticTokenType::FUNCTION,
                                        ],
                                        token_modifiers: vec![],
                                    },
                                    full: Some(SemanticTokensFullOptions::Bool(true)),
                                    range: None,
                                    work_done_progress_options: Default::default(),
                                },
                            ),
                        ),

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
                        LexerParserState::new(params.text_document.text, &builder),
                    );
                }
            }
            (Some(m), None) if m == DidChangeTextDocument::METHOD => {
                if let Some(params) = rpc.params.as_ref().and_then(|v| {
                    serde_json::from_value::<DidChangeTextDocumentParams>(v.clone()).ok()
                }) {
                    let state = docs.get_mut(&params.text_document.uri).unwrap();
                    for change in params.content_changes {
                        let start = state
                            .lexer_state
                            .offset_from_position(&change.range.unwrap().start);
                        let end = state
                            .lexer_state
                            .offset_from_position(&change.range.unwrap().end);

                        let edit = TextEdit {
                            remove: start..end,
                            text: change.text,
                        };
                        let stats = state.edit(&edit);
                        let mut edit_start = Pos::zero();
                        for tok in &state.lexer_state.tokens[..stats.changed.start] {
                            edit_start += tok.relative_pos
                        }
                        let mut edit_end = edit_start;
                        for tok in &state.lexer_state.tokens[stats.changed.start..stats.changed.end]
                        {
                            edit_end += tok.relative_pos
                        }
                        server_diags(
                            &mut stdout,
                            vec![Diagnostic::new_simple(
                                Range {
                                    start: edit_start.to_lsp_pos(),
                                    end: edit_end.to_lsp_pos(),
                                },
                                "Updated".to_string(),
                            )],
                            params.text_document.uri.clone(),
                        )
                        .unwrap();
                        // server_show_message(&mut stdout, MessageType::ERROR, format!("{stats:#?}"))
                        //     .unwrap()
                    }
                }
            }

            (Some(m), Some(id)) if m == DocumentSymbolRequest::METHOD => {
                let params: lsp_types::DocumentSymbolParams = rpc
                    .params
                    .as_ref()
                    .and_then(|v| serde_json::from_value(v.clone()).ok())
                    .unwrap();

                let uri = params.text_document.uri;

                let symbols = docs
                    .get(&uri)
                    .map(|state| vec![state.document_symbols()])
                    .unwrap_or_default();

                let result = DocumentSymbolResponse::Nested(symbols);

                let resp = RpcResponse::result(id, serde_json::to_value(result).unwrap());
                write_lsp_response(&mut stdout, &resp).unwrap();
            }

            (Some(m), Some(id)) if m == SemanticTokensFullRequest::METHOD => {
                use lsp_types::{SemanticTokens, SemanticTokensResult};
                use std::collections::HashMap;

                let params: lsp_types::SemanticTokensParams = rpc
                    .params
                    .as_ref()
                    .and_then(|v| serde_json::from_value(v.clone()).ok())
                    .unwrap();

                let uri = params.text_document.uri;

                let Some(symbols) = docs
                    .get(&uri)
                    .map(|state| state.lexer_state.tokens.as_slice())
                else {
                    return;
                };

                // Your mapping: Tok.kind -> LSP semantic token kind index
                let mut kind_to_semantic: HashMap<u32, u32> = HashMap::new();
                kind_to_semantic.insert(1, 1);
                kind_to_semantic.insert(2, 2);

                let data = semantic_tokens_structured(symbols, &kind_to_semantic);

                let result = SemanticTokensResult::Tokens(SemanticTokens {
                    result_id: None,
                    data,
                });

                let resp = RpcResponse::result(id, serde_json::to_value(result).unwrap());
                write_lsp_response(&mut stdout, &resp).unwrap();
            }
            // (Some(m), Some(id)) if m == SemanticTokensRangeRequest::METHOD => {}
            (Some(m), None) if m == Exit::METHOD => {
                // If we already got shutdown, exit 0; otherwise 1.
                // Minimal: just exit 0.
                break;
            }

            // Unknown request -> Method not found (-32601)
            (Some(m), Some(id)) => {
                let resp = RpcResponse::error(id, -32601, format!("Method not found: {m}"));
                write_lsp_response(&mut stdout, &resp).unwrap();
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

fn server_show_message<W: Write>(w: &mut W, typ: MessageType, message: String) -> io::Result<()> {
    // window/showMessage notification
    #[derive(Serialize)]
    struct Params {
        #[serde(rename = "type")]
        typ: MessageType,
        message: String,
    }

    #[derive(Serialize)]
    struct Notif<'a> {
        jsonrpc: &'static str,
        method: &'a str,
        params: Params,
    }

    let notif = Notif {
        jsonrpc: "2.0",
        method: "window/showMessage",
        params: Params { typ, message },
    };

    let body = serde_json::to_vec(&notif)
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

fn server_diags<W: Write>(w: &mut W, diags: Vec<Diagnostic>, uri: Uri) -> io::Result<()> {
    #[derive(Serialize)]
    struct Notif<'a> {
        jsonrpc: &'static str,
        method: &'a str,
        params: PublishDiagnosticsParams,
    }

    let notif = Notif {
        jsonrpc: "2.0",
        method: "textDocument/publishDiagnostics",
        params: PublishDiagnosticsParams {
            uri,
            diagnostics: diags,
            version: None,
        },
    };

    let body = serde_json::to_vec(&notif)
        .map_err(|e| io::Error::new(io::ErrorKind::InvalidData, e.to_string()))?;
    write!(w, "Content-Length: {}\r\n\r\n", body.len())?;
    w.write_all(&body)?;
    w.flush()?;
    Ok(())
}
