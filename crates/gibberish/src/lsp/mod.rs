use crate::ast::{CheckError, CheckState, LspItem as _, RootAst};
use crate::lsp::semantic_token::{ImCompleteSemanticToken, LEGEND_TYPE, semantic_token_from_ast};
use dashmap::DashMap;
use gibberish_core::err::ParseError;
use gibberish_core::node::Node;
use gibberish_gibberish_parser::Gibberish;
use log::debug;
use ropey::Rope;
use serde::{Deserialize, Serialize};
use serde_json::Value;
use tower_lsp::jsonrpc::Result;
use tower_lsp::lsp_types::notification::Notification;
use tower_lsp::lsp_types::*;
use tower_lsp::{Client, LanguageServer, LspService, Server};

#[derive(Debug)]
struct Backend {
    client: Client,
    ast_map: DashMap<String, Node<Gibberish>>,
    document_map: DashMap<String, Rope>,
    semantic_token_map: DashMap<String, Vec<ImCompleteSemanticToken>>,
}

pub mod funcs;
pub mod semantic_token;
pub mod span;

#[tower_lsp::async_trait]
impl LanguageServer for Backend {
    async fn initialize(&self, _: InitializeParams) -> Result<InitializeResult> {
        Ok(InitializeResult {
            server_info: None,
            offset_encoding: None,
            capabilities: ServerCapabilities {
                hover_provider: Some(HoverProviderCapability::Simple(true)),
                inlay_hint_provider: Some(OneOf::Left(true)),
                text_document_sync: Some(TextDocumentSyncCapability::Options(
                    TextDocumentSyncOptions {
                        open_close: Some(true),
                        change: Some(TextDocumentSyncKind::FULL),
                        save: Some(TextDocumentSyncSaveOptions::SaveOptions(SaveOptions {
                            include_text: Some(true),
                        })),
                        ..Default::default()
                    },
                )),
                completion_provider: Some(CompletionOptions {
                    resolve_provider: Some(false),
                    trigger_characters: None,
                    work_done_progress_options: Default::default(),
                    all_commit_characters: None,
                    completion_item: None,
                }),
                execute_command_provider: Some(ExecuteCommandOptions {
                    commands: vec!["dummy.do_something".to_string()],
                    work_done_progress_options: Default::default(),
                }),

                workspace: Some(WorkspaceServerCapabilities {
                    workspace_folders: Some(WorkspaceFoldersServerCapabilities {
                        supported: Some(true),
                        change_notifications: Some(OneOf::Left(true)),
                    }),
                    file_operations: None,
                }),
                semantic_tokens_provider: Some(
                    SemanticTokensServerCapabilities::SemanticTokensRegistrationOptions(
                        SemanticTokensRegistrationOptions {
                            text_document_registration_options: {
                                TextDocumentRegistrationOptions {
                                    document_selector: Some(vec![DocumentFilter {
                                        language: Some("nrs".to_string()),
                                        scheme: Some("file".to_string()),
                                        pattern: None,
                                    }]),
                                }
                            },
                            semantic_tokens_options: SemanticTokensOptions {
                                work_done_progress_options: WorkDoneProgressOptions::default(),
                                legend: SemanticTokensLegend {
                                    token_types: LEGEND_TYPE.into(),
                                    token_modifiers: vec![],
                                },
                                range: Some(true),
                                full: Some(SemanticTokensFullOptions::Bool(true)),
                            },
                            static_registration_options: StaticRegistrationOptions::default(),
                        },
                    ),
                ),
                // definition: Some(GotoCapability::default()),
                definition_provider: Some(OneOf::Left(true)),
                references_provider: Some(OneOf::Left(true)),
                rename_provider: Some(OneOf::Left(true)),
                ..ServerCapabilities::default()
            },
        })
    }
    async fn initialized(&self, _: InitializedParams) {
        debug!("initialized!");
    }

    async fn shutdown(&self) -> Result<()> {
        Ok(())
    }

    async fn did_open(&self, params: DidOpenTextDocumentParams) {
        debug!("file opened");
        self.on_change(TextDocumentItem {
            uri: params.text_document.uri,
            text: &params.text_document.text,
            version: Some(params.text_document.version),
        })
        .await
    }

    async fn did_change(&self, params: DidChangeTextDocumentParams) {
        self.on_change(TextDocumentItem {
            text: &params.content_changes[0].text,
            uri: params.text_document.uri,
            version: Some(params.text_document.version),
        })
        .await
    }

    async fn did_save(&self, params: DidSaveTextDocumentParams) {
        if let Some(text) = params.text {
            let item = TextDocumentItem {
                uri: params.text_document.uri,
                text: &text,
                version: None,
            };
            self.on_change(item).await;
            _ = self.client.semantic_tokens_refresh().await;
        }
        debug!("file saved!");
    }
    async fn did_close(&self, _: DidCloseTextDocumentParams) {
        debug!("file closed!");
    }

    async fn goto_definition(
        &self,
        params: GotoDefinitionParams,
    ) -> Result<Option<GotoDefinitionResponse>> {
        let definition = || -> Option<GotoDefinitionResponse> {
            let uri = params.text_document_position_params.text_document.uri;
            let rope = self.document_map.get(uri.as_str())?;
            let position = params.text_document_position_params.position;
            let offset = position_to_offset(position, &rope)?;
            let ast = self.ast_map.get(uri.as_str()).unwrap();
            let root = RootAst(ast.as_group());
            let mut state = CheckState::default();
            root.check(&mut state);

            let node = root.at(offset);
            let node = node?;
            let range = node.definition(&state);

            range.and_then(|range| {
                let start_position = offset_to_position(range.start, &rope)?;
                let end_position = offset_to_position(range.end, &rope)?;
                Some(GotoDefinitionResponse::Scalar(Location::new(
                    uri,
                    Range::new(start_position, end_position),
                )))
            })
        }();
        Ok(definition)
    }

    async fn references(&self, params: ReferenceParams) -> Result<Option<Vec<Location>>> {
        let reference_list = || -> Option<Vec<Location>> {
            let uri = params.text_document_position.text_document.uri;
            let rope = self.document_map.get(uri.as_str())?;
            let position = params.text_document_position.position;
            let offset = position_to_offset(position, &rope)?;
            let ast = self.ast_map.get(uri.as_str()).unwrap();

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

    async fn semantic_tokens_full(
        &self,
        params: SemanticTokensParams,
    ) -> Result<Option<SemanticTokensResult>> {
        let uri = params.text_document.uri.to_string();
        debug!("semantic_token_full");
        let semantic_tokens = || -> Option<Vec<SemanticToken>> {
            let mut im_complete_tokens = self.semantic_token_map.get_mut(&uri)?;
            let rope = self.document_map.get(&uri)?;
            let ast = self.ast_map.get(uri.as_str()).unwrap();
            let root = RootAst(ast.as_group());
            let mut state = CheckState::default();
            root.check(&mut state);

            for call in &state.func_calls {
                let token_type = LEGEND_TYPE
                    .iter()
                    .position(|item| *item == SemanticTokenType::FUNCTION)
                    .unwrap();
                im_complete_tokens.push(ImCompleteSemanticToken {
                    start: call.start,
                    length: call.len(),
                    token_type,
                });
            }

            im_complete_tokens.sort_by(|a, b| a.start.cmp(&b.start));
            let mut pre_line = 0;
            let mut pre_start = 0;

            let semantic_tokens = im_complete_tokens
                .iter()
                .filter_map(|token| {
                    let line = rope.try_byte_to_line(token.start).ok()? as u32;
                    let first = rope.try_line_to_char(line as usize).ok()? as u32;
                    let start = rope.try_byte_to_char(token.start).ok()? as u32 - first;
                    let delta_line = line - pre_line;
                    let delta_start = if delta_line == 0 {
                        start - pre_start
                    } else {
                        start
                    };
                    let ret = Some(SemanticToken {
                        delta_line,
                        delta_start,
                        length: token.length as u32,
                        token_type: token.token_type as u32,
                        token_modifiers_bitset: 0,
                    });
                    pre_line = line;
                    pre_start = start;
                    ret
                })
                .collect::<Vec<_>>();
            Some(semantic_tokens)
        }();
        if let Some(semantic_token) = semantic_tokens {
            return Ok(Some(SemanticTokensResult::Tokens(SemanticTokens {
                result_id: None,
                data: semantic_token,
            })));
        }
        Ok(None)
    }

    async fn semantic_tokens_range(
        &self,
        params: SemanticTokensRangeParams,
    ) -> Result<Option<SemanticTokensRangeResult>> {
        let uri = params.text_document.uri.to_string();
        let semantic_tokens = || -> Option<Vec<SemanticToken>> {
            let im_complete_tokens = self.semantic_token_map.get(&uri)?;
            let rope = self.document_map.get(&uri)?;
            let mut pre_line = 0;
            let mut pre_start = 0;
            let semantic_tokens = im_complete_tokens
                .iter()
                .filter_map(|token| {
                    let line = rope.try_byte_to_line(token.start).ok()? as u32;
                    let first = rope.try_line_to_char(line as usize).ok()? as u32;
                    let start = rope.try_byte_to_char(token.start).ok()? as u32 - first;
                    let ret = Some(SemanticToken {
                        delta_line: line - pre_line,
                        delta_start: if start >= pre_start {
                            start - pre_start
                        } else {
                            start
                        },
                        length: token.length as u32,
                        token_type: token.token_type as u32,
                        token_modifiers_bitset: 0,
                    });
                    pre_line = line;
                    pre_start = start;
                    ret
                })
                .collect::<Vec<_>>();
            Some(semantic_tokens)
        }();
        Ok(semantic_tokens.map(|data| {
            SemanticTokensRangeResult::Tokens(SemanticTokens {
                result_id: None,
                data,
            })
        }))
    }

    async fn hover(&self, params: HoverParams) -> Result<Option<Hover>> {
        dbg!("Hover");
        let hover = || -> Option<Hover> {
            let uri = params.text_document_position_params.text_document.uri;
            let rope = self.document_map.get(uri.as_str())?;
            let position = params.text_document_position_params.position;
            let offset = position_to_offset(position, &rope)?;
            let ast = self.ast_map.get(uri.as_str()).unwrap();
            let root = RootAst(ast.as_group());

            let node = root.at(offset);

            let mut state = CheckState::default();
            root.check(&mut state);

            let Some(node) = node else {
                dbg!("Couldn't find 'at' node");
                return None;
            };

            if let Some(contents) = node.hover(&state) {
                dbg!("Found hover {contents:?}");
                Some(Hover {
                    contents,
                    range: None,
                })
            } else {
                dbg!("No hover found");
                None
            }
        }();
        Ok(hover)
    }

    async fn inlay_hint(
        &self,
        _: tower_lsp::lsp_types::InlayHintParams,
    ) -> Result<Option<Vec<InlayHint>>> {
        todo!()
    }

    async fn completion(&self, params: CompletionParams) -> Result<Option<CompletionResponse>> {
        dbg!("Completions");
        let completions = || -> Option<CompletionResponse> {
            let uri = params.text_document_position.text_document.uri;
            let rope = self.document_map.get(uri.as_str())?;
            let position = params.text_document_position.position;
            let offset = position_to_offset(position, &rope)?;
            let ast = self.ast_map.get(uri.as_str()).unwrap();
            let completions = ast.as_group().completions_at(offset);
            Some(CompletionResponse::Array(
                completions
                    .iter()
                    .map(|it| {
                        let mut completion = CompletionItem::new_simple(
                            "completion".to_string(),
                            it.debug_name(&Gibberish),
                        );
                        completion.kind = Some(CompletionItemKind::SNIPPET);
                        completion
                    })
                    .collect(),
            ))
        }();
        dbg!("Got completions", &completions);
        Ok(completions)
    }

    async fn rename(&self, _: RenameParams) -> Result<Option<WorkspaceEdit>> {
        Ok(None)
    }

    async fn did_change_configuration(&self, _: DidChangeConfigurationParams) {
        debug!("configuration changed!");
    }

    async fn did_change_workspace_folders(&self, _: DidChangeWorkspaceFoldersParams) {
        debug!("workspace folders changed!");
    }

    async fn did_change_watched_files(&self, _: DidChangeWatchedFilesParams) {
        debug!("watched files have changed!");
    }

    async fn execute_command(&self, _: ExecuteCommandParams) -> Result<Option<Value>> {
        debug!("command executed!");

        match self.client.apply_edit(WorkspaceEdit::default()).await {
            Ok(res) if res.applied => self.client.log_message(MessageType::INFO, "applied").await,
            Ok(_) => self.client.log_message(MessageType::INFO, "rejected").await,
            Err(err) => self.client.log_message(MessageType::ERROR, err).await,
        }

        Ok(None)
    }
}
#[derive(Debug, Deserialize, Serialize)]
struct InlayHintParams {
    path: String,
}

#[allow(unused)]
enum CustomNotification {}
impl Notification for CustomNotification {
    type Params = InlayHintParams;
    const METHOD: &'static str = "custom/notification";
}
struct TextDocumentItem<'a> {
    uri: Url,
    text: &'a str,
    version: Option<i32>,
}

impl Backend {
    async fn on_change<'a>(&self, params: TextDocumentItem<'a>) {
        let rope = ropey::Rope::from_str(params.text);
        self.document_map
            .insert(params.uri.to_string(), rope.clone());
        let lst = Gibberish::parse(params.text);
        let mut diagnostics = lst
            .all_leading_errors()
            .filter_map(|(_, err)| {
                let (message, _) = match err {
                    ParseError::MissingError { start, expected } => {
                        let expected_txt = expected
                            .iter()
                            .map(|it| it.debug_name(&Gibberish))
                            .collect::<Vec<_>>()
                            .join(",");
                        let span = *start..*start;
                        (format!("Missing {expected_txt}"), span)
                    }
                    ParseError::Unexpected { start, actual } => {
                        if let (Some(first), Some(last)) = (actual.first(), actual.last()) {
                            let span = first.span.start..last.span.end;
                            ("This is unexpected".to_string(), span)
                        } else {
                            ("This is unexpected".to_string(), *start..*start)
                        }
                    }
                };
                let start_position = offset_to_position(err.span().start, &rope)?;
                let end_position = offset_to_position(err.span().end, &rope)?;
                Some(Diagnostic::new_simple(
                    Range::new(start_position, end_position),
                    message,
                ))
            })
            .collect::<Vec<_>>();

        let ast = RootAst(lst.as_group());
        let diags = {
            let mut state = CheckState::default();
            ast.check(&mut state);
            state.errors
        };
        let semantic_tokens = semantic_token_from_ast(&ast);

        self.ast_map.insert(params.uri.to_string(), lst);
        for err in diags {
            match err {
                CheckError::Simple {
                    message,
                    span,
                    severity,
                } => {
                    let start_position = offset_to_position(span.start, &rope).unwrap();
                    let end_position = offset_to_position(span.end, &rope).unwrap();
                    let range = Range::new(start_position, end_position);
                    let mut diag = Diagnostic::new_simple(range, message);
                    diag.severity = Some(severity);
                    diagnostics.push(diag);
                }
                CheckError::Unused(span) => {
                    let start_position = offset_to_position(span.start, &rope).unwrap();
                    let end_position = offset_to_position(span.end, &rope).unwrap();
                    let range = Range::new(start_position, end_position);
                    let mut diag =
                        Diagnostic::new_simple(range, "This variable is never used".to_string());
                    diag.severity = Some(DiagnosticSeverity::WARNING);
                    diag.tags = Some(vec![DiagnosticTag::UNNECESSARY]);
                    diagnostics.push(diag);
                }
                CheckError::Redeclaration {
                    previous,
                    this,
                    name,
                } => {
                    let start_position = offset_to_position(this.start, &rope).unwrap();
                    let end_position = offset_to_position(this.end, &rope).unwrap();
                    let this_range = Range::new(start_position, end_position);

                    let start_position = offset_to_position(previous.start, &rope).unwrap();
                    let end_position = offset_to_position(previous.end, &rope).unwrap();
                    let prev_range = Range::new(start_position, end_position);

                    let mut diag = Diagnostic::new_simple(
                        this_range,
                        format!("Variable '{name}' is already defined"),
                    );

                    diag.severity = Some(DiagnosticSeverity::ERROR);

                    diag.related_information = Some(vec![DiagnosticRelatedInformation {
                        location: Location {
                            uri: params.uri.clone(),
                            range: prev_range,
                        },
                        message: format!("Previous definition of '{name}'"),
                    }]);
                    diagnostics.push(diag);
                }
            }
        }

        self.client
            .publish_diagnostics(params.uri.clone(), diagnostics, params.version)
            .await;
        self.semantic_token_map
            .insert(params.uri.to_string(), semantic_tokens);
    }
}

pub async fn start_lsp() {
    env_logger::init();

    let stdin = tokio::io::stdin();
    let stdout = tokio::io::stdout();

    let (service, socket) = LspService::build(|client| Backend {
        client,
        ast_map: DashMap::new(),
        document_map: DashMap::new(),
        semantic_token_map: DashMap::new(),
    })
    .finish();

    Server::new(stdin, stdout, socket).serve(service).await;
}

fn offset_to_position(offset: usize, rope: &Rope) -> Option<Position> {
    let line = rope.try_char_to_line(offset).ok()?;
    let first_char_of_line = rope.try_line_to_char(line).ok()?;
    let column = offset - first_char_of_line;
    Some(Position::new(line as u32, column as u32))
}

fn position_to_offset(position: Position, rope: &Rope) -> Option<usize> {
    let line_char_offset = rope.try_line_to_char(position.line as usize).ok()?;
    let slice = rope.slice(0..line_char_offset + position.character as usize);
    Some(slice.len_bytes())
}
