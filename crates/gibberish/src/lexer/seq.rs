use std::fmt::Write;

use crate::lexer::{RegexAst, build::LexerBuilderState, parse_regex};

pub fn parse_seq(regex: &str, offset: &mut usize) -> Option<RegexAst> {
    let mut res = vec![];
    loop {
        if matches!(regex.chars().nth(*offset), None | Some('|') | Some(')')) {
            return Some(RegexAst::Seq(res));
        }
        let mut item = parse_regex(regex, offset)?;
        if let Some('*') = regex.chars().nth(*offset) {
            *offset += 1;
            item = RegexAst::Rep0(Box::new(item));
        }
        if let Some('+') = regex.chars().nth(*offset) {
            *offset += 1;
            item = RegexAst::Rep1(Box::new(item));
        }
        res.push(item);
    }
}

pub fn build_seq_regex(
    state: &mut LexerBuilderState,
    f: &mut impl Write,
    parts: &[RegexAst],
) -> usize {
    let id = state.id();

    let built_parts = parts
        .iter()
        .map(|it| it.build(state, f))
        .collect::<Vec<_>>();

    writeln!(
        f,
        r#"
/* RegexSeq */
static bool lex_{id}(LexerState *lexer_state) {{
    size_t start = lexer_state->offset;
"#,
    )
    .unwrap();

    for part in &built_parts {
        writeln!(
            f,
            r#"
    if (!lex_{part}(lexer_state)) {{
        lexer_state->offset = start;
        return false;
    }}
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
