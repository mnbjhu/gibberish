use gibberish_gibberish_parser::GibberishToken;
use tower_lsp::jsonrpc::Result;
use tower_lsp::lsp_types::{
    SemanticToken, SemanticTokenType, SemanticTokens, SemanticTokensParams,
    SemanticTokensRangeParams, SemanticTokensRangeResult, SemanticTokensResult,
};

use crate::ast::CheckState;
use crate::{ast::RootAst, lsp::Backend};

#[derive(Debug)]
pub struct ImCompleteSemanticToken {
    pub start: usize,
    pub length: usize,
    pub token_type: usize,
}

pub const LEGEND_TYPE: &[SemanticTokenType] = &[
    SemanticTokenType::FUNCTION,
    SemanticTokenType::VARIABLE,
    SemanticTokenType::STRING,
    SemanticTokenType::COMMENT,
    SemanticTokenType::NUMBER,
    SemanticTokenType::KEYWORD,
    SemanticTokenType::OPERATOR,
    SemanticTokenType::PARAMETER,
    SemanticTokenType::TYPE,
    SemanticTokenType::DECORATOR,
    SemanticTokenType::PROPERTY,
];

use GibberishToken as T;
use SemanticTokenType as Sem;

pub fn semantic_token_from_ast(ast: &RootAst) -> Vec<ImCompleteSemanticToken> {
    let mut semantic_tokens = vec![];

    ast.0.all_tokens().for_each(|it| {
        let kind = match it.kind {
            T::Int => Some(Sem::NUMBER),
            T::String => Some(Sem::STRING),
            T::PARSER | T::KEYWORD | T::TOKEN | T::FOLD => Some(Sem::KEYWORD),
            _ => None,
        };
        if let Some(kind) = kind {
            semantic_tokens.push(ImCompleteSemanticToken {
                start: it.span.start,
                length: it.span.len(),
                token_type: LEGEND_TYPE.iter().position(|item| item == &kind).unwrap(),
            });
        }
    });

    semantic_tokens
}
pub async fn semantic_tokens_range(
    backend: &Backend,
    params: SemanticTokensRangeParams,
) -> Result<Option<SemanticTokensRangeResult>> {
    let uri = params.text_document.uri.to_string();
    let semantic_tokens = || -> Option<Vec<SemanticToken>> {
        let im_complete_tokens = backend.semantic_token_map.get(&uri)?;
        let rope = backend.document_map.get(&uri)?;
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

pub async fn semantic_tokens_full(
    backend: &Backend,
    params: SemanticTokensParams,
) -> Result<Option<SemanticTokensResult>> {
    let uri = params.text_document.uri.to_string();
    let semantic_tokens = || -> Option<Vec<SemanticToken>> {
        let mut im_complete_tokens = backend.semantic_token_map.get_mut(&uri)?;
        let rope = backend.document_map.get(&uri)?;
        let ast = backend.ast_map.get(uri.as_str()).unwrap();
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
