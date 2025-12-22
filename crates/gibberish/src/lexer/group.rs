use std::fmt::Write;

use crate::lexer::{RegexAst, build::LexerBuilderState, seq::parse_seq};

pub fn parse_capture(regex: &str, offset: &mut usize) -> bool {
    if !matches!(regex.chars().nth(*offset), Some('?')) {
        return true;
    }
    if !matches!(regex.chars().nth(*offset + 1), Some(':')) {
        return true;
    }
    *offset += 2;
    false
}

pub fn parse_group(regex: &str, offset: &mut usize) -> Option<RegexAst> {
    if !matches!(regex.chars().nth(*offset), Some('(')) {
        return None;
    }
    *offset += 1;
    let capture = parse_capture(regex, offset);
    let mut options = vec![];
    loop {
        options.push(parse_seq(regex, offset)?);
        let current = regex.chars().nth(*offset)?;
        if current == ')' {
            *offset += 1;
            break;
        }
        if current == '|' {
            *offset += 1;
            continue;
        } else {
            return None;
        }
    }
    assert_ne!(options.len(), 0);
    Some(RegexAst::Group { options, capture })
}

pub fn build_group_regex(
    state: &mut LexerBuilderState,
    f: &mut impl Write,
    options: &[RegexAst],
    capture: bool,
) -> usize {
    let id = state.id();

    let parts = options
        .iter()
        .map(|it| it.build(state, f))
        .collect::<Vec<_>>();

    writeln!(
        f,
        r#"
/* RegexGroup */
static bool lex_{id}(LexerState *lexer_state) {{
    size_t start = lexer_state->offset;
"#,
    )
    .unwrap();

    // Try each option from the same starting offset.
    for part in &parts {
        writeln!(
            f,
            r#"
    lexer_state->offset = start;
    if (lex_{part}(lexer_state)) {{
"#,
        )
        .unwrap();

        if capture {
            writeln!(
                f,
                r#"        lexer_state->group_offset = lexer_state->offset;"#
            )
            .unwrap();
        }

        writeln!(
            f,
            r#"        return true;
    }}"#
        )
        .unwrap();
    }

    // All options failed
    writeln!(
        f,
        r#"
    lexer_state->offset = start;
    return false;
}}
"#,
    )
    .unwrap();

    id
}
