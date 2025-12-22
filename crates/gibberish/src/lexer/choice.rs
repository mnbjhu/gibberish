use std::fmt::Write;

use crate::lexer::{
    RegexAst,
    build::LexerBuilderState,
    option::{OptionAst, parse_option},
};

pub fn parse_choice(regex: &str, offset: &mut usize) -> Option<RegexAst> {
    let Some('[') = regex.chars().nth(*offset) else {
        return None;
    };
    *offset += 1;

    let negate = if let Some('^') = regex.chars().nth(*offset) {
        *offset += 1;
        true
    } else {
        false
    };

    let mut options = vec![];

    while let Some(current) = regex.chars().nth(*offset) {
        if current == ']' {
            *offset += 1;
            return Some(RegexAst::Choice { negate, options });
        };
        options.push(parse_option(regex, offset)?);
    }
    None
}

pub fn build_choice_regex(
    state: &mut LexerBuilderState,
    f: &mut impl Write,
    options: &[OptionAst],
) -> usize {
    let id = state.id();

    // Build sub-regex functions first (same as your old flow)
    let parts = options
        .iter()
        .map(|it| it.build(state, f))
        .collect::<Vec<_>>();

    // Emit C for the choice
    writeln!(
        f,
        r#"
/* RegexChoice */
static bool lex_{id}(LexerState *lexer_state) {{
    size_t start = lexer_state->offset;

"#,
    )
    .unwrap();

    // Try each part in order; reset offset before each attempt.
    for part in &parts {
        writeln!(
            f,
            r#"    lexer_state->offset = start;
    if (lex_{part}(lexer_state)) {{
        return true;
    }}

"#,
        )
        .unwrap();
    }

    // Total failure: restore offset and return false.
    writeln!(
        f,
        r#"    lexer_state->offset = start;
    return false;
}}
"#,
    )
    .unwrap();

    id
}

pub fn build_negated_choice_regex(
    state: &mut LexerBuilderState,
    f: &mut impl Write,
    options: &[OptionAst],
) -> usize {
    let id = state.id();

    // Build sub-regex functions first
    let parts = options
        .iter()
        .map(|it| it.build(state, f))
        .collect::<Vec<_>>();

    writeln!(
        f,
        r#"
/* RegexNegatedChoice */
static bool lex_{id}(LexerState *lexer_state) {{
    size_t len = lexer_state->len;
    size_t start = lexer_state->offset;

"#,
    )
    .unwrap();

    // Try each option in order; if any succeeds -> fail.
    for part in &parts {
        writeln!(
            f,
            r#"    if (lex_{part}(lexer_state)) {{
        lexer_state->offset = start;
        return false;
    }}
"#,
        )
        .unwrap();
    }

    // None matched: succeed; consume one char unless we're at EOF.
    writeln!(
        f,
        r#"
    if (lexer_state->offset == len) {{
        return true; /* EOF: succeed without consuming */
    }}

    lexer_state->offset += 1; /* consume one byte/char */
    return true;
}}
"#,
    )
    .unwrap();

    id
}
