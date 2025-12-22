use std::fmt::Write;

use crate::lexer::{RegexAst, build::LexerBuilderState};

pub fn parse_exact(regex: &str, offset: &mut usize) -> Option<RegexAst> {
    let start = *offset;
    loop {
        match regex.chars().nth(*offset) {
            Some('|') | Some('[') | Some(']') | Some('(') | Some(')') | Some('\\') | None => break,
            _ => *offset += 1,
        }
    }
    if start == *offset {
        None
    } else {
        Some(RegexAst::Exact(regex[start..*offset].to_string()))
    }
}

pub fn build_exact_regex(f: &mut impl Write, state: &mut LexerBuilderState, text: &str) -> usize {
    let id = state.id();

    writeln!(
        f,
        r#"
/* Exact */
static bool lex_{id}(LexerState *lexer_state) {{
    size_t start = lexer_state->offset;
"#,
    )
    .unwrap();

    for &b in text.as_bytes() {
        writeln!(
            f,
            r#"
    if (lexer_state->offset >= lexer_state->len) {{
        lexer_state->offset = start;
        return false;
    }}
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char){b}) {{
        lexer_state->offset = start;
        return false;
    }}
    lexer_state->offset += 1;
"#,
        )
        .unwrap();
    }

    writeln!(
        f,
        r#"
    return true;
}}
"#,
    )
    .unwrap();

    id
}
