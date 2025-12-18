use gibberish_gibberish_parser::GibberishToken;
use tower_lsp::lsp_types::SemanticTokenType;

use crate::ast::RootAst;

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
