use crate::runtime::lexer::{pos::Pos, token::Tok};
use std::collections::HashMap;

fn u32_try(x: usize) -> u32 {
    u32::try_from(x).unwrap_or(u32::MAX)
}

pub fn semantic_tokens_structured(
    toks: &[Tok],
    kind_to_semantic: &HashMap<u32, u32>,
) -> Vec<lsp_types::SemanticToken> {
    // Cursor is the absolute START position of the current token.
    let mut cursor = Pos::zero();

    // Track the last emitted token START position for LSP delta encoding.
    let mut last_line: usize = 0;
    let mut last_char: usize = 0;
    let mut have_last = false;

    let mut out = Vec::new();

    for tok in toks {
        // Token starts at `cursor`
        let start = cursor;

        // If this token kind maps to a semantic token type, emit it.
        if let Some(&token_type) = kind_to_semantic.get(&tok.kind) {
            let length = u32_try(tok.relative_pos.offset);
            let token_modifiers_bitset = 0u32;

            let (delta_line, delta_start) = if !have_last {
                have_last = true;
                last_line = start.line;
                last_char = start.char;
                (u32_try(start.line), u32_try(start.char))
            } else {
                let dl = start.line.saturating_sub(last_line);
                let ds = if dl == 0 {
                    start.char.saturating_sub(last_char)
                } else {
                    start.char
                };

                last_line = start.line;
                last_char = start.char;

                (u32_try(dl), u32_try(ds))
            };

            out.push(lsp_types::SemanticToken {
                delta_line,
                delta_start,
                length,
                token_type,
                token_modifiers_bitset,
            });
        }

        // Advance cursor from token START to token END using the token's relative end position.
        // - offset: token length
        // - char/line: end position relative to start
        cursor += tok.relative_pos;
    }

    out
}
