use async_lsp::lsp_types::{Position, Range};

pub mod capabilities;
pub mod diags;
pub mod document_symbols;
pub mod semantic_tokens;

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
