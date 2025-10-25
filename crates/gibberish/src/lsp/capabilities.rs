use async_lsp::lsp_types::{
    CompletionOptions, HoverProviderCapability, InitializeResult, OneOf, SemanticTokenType,
    SemanticTokensFullOptions, SemanticTokensLegend, SemanticTokensOptions,
    SemanticTokensServerCapabilities, ServerCapabilities, TextDocumentSyncCapability,
    TextDocumentSyncKind,
};

pub fn capabilities() -> InitializeResult {
    InitializeResult {
        capabilities: ServerCapabilities {
            hover_provider: Some(HoverProviderCapability::Simple(true)),
            definition_provider: Some(OneOf::Left(true)),
            text_document_sync: Some(TextDocumentSyncCapability::Kind(TextDocumentSyncKind::FULL)),
            document_symbol_provider: Some(OneOf::Left(true)),
            semantic_tokens_provider: Some(
                SemanticTokensServerCapabilities::SemanticTokensOptions(SemanticTokensOptions {
                    legend: SemanticTokensLegend {
                        token_types: vec![
                            SemanticTokenType::KEYWORD,
                            SemanticTokenType::VARIABLE,
                            SemanticTokenType::FUNCTION,
                            SemanticTokenType::STRING,
                            SemanticTokenType::NUMBER,
                            SemanticTokenType::COMMENT,
                            SemanticTokenType::TYPE,
                            SemanticTokenType::PARAMETER,
                            SemanticTokenType::PROPERTY,
                            SemanticTokenType::STRUCT,
                            SemanticTokenType::ENUM,
                            SemanticTokenType::ENUM_MEMBER,
                            SemanticTokenType::INTERFACE,
                            SemanticTokenType::NAMESPACE,
                            SemanticTokenType::STRING,
                            SemanticTokenType::NUMBER,
                            SemanticTokenType::COMMENT,
                            SemanticTokenType::MODIFIER,
                        ],
                        token_modifiers: vec![],
                    },
                    full: Some(SemanticTokensFullOptions::Delta { delta: Some(true) }),
                    ..Default::default()
                }),
            ),
            document_formatting_provider: Some(OneOf::Left(true)),
            completion_provider: Some(CompletionOptions {
                trigger_characters: Some(vec![
                    ":".to_string(),
                    ".".to_string(),
                    "/\\w+/".to_string(),
                ]),
                ..Default::default()
            }),
            ..ServerCapabilities::default()
        },
        server_info: None,
    }
}
