use std::{
    fmt::{Display, Write},
    ops::RangeInclusive,
};

use crate::lexer::{RegexAst, build::LexerBuilderState, parse_special};

#[derive(Debug)]
pub enum OptionAst {
    Range(RangeInclusive<u8>),
    Char(u8),
    Regex(RegexAst),
}

pub fn parse_option(regex: &str, offset: &mut usize) -> Option<OptionAst> {
    if let Some(special) = parse_special(regex, offset) {
        return Some(OptionAst::Regex(special));
    }
    match regex.chars().nth(*offset) {
        Some(char) => {
            *offset += 1;
            if let Some('-') = regex.chars().nth(*offset) {
                *offset += 1;
                let end = regex.chars().nth(*offset)?;
                *offset += 1;
                Some(OptionAst::Range(char as u8..=end as u8))
            } else {
                Some(OptionAst::Char(char as u8))
            }
        }
        _ => None,
    }
}

impl Display for OptionAst {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            OptionAst::Range(range) => {
                write!(f, "{}-{}", *range.start() as char, *range.end() as char)
            }
            OptionAst::Char(c) => write!(f, "{}", *c as char),
            OptionAst::Regex(_) => todo!(),
        }
    }
}

impl OptionAst {
    pub fn build(&self, state: &mut LexerBuilderState, f: &mut impl Write) -> usize {
        let id = state.id();

        match self {
            OptionAst::Range(range) => {
                // range.start / range.end are assumed to already be numeric byte values (0..=255)
                writeln!(
                    f,
                    r#"
/* RegexRange */
static bool lex_{id}(LexerState *lexer_state) {{
    if (lexer_state->offset >= lexer_state->len) {{
        return false; /* EOF */
    }}

    unsigned char current = (unsigned char)lexer_state->data[lexer_state->offset];
    if (current >= (unsigned char){start} && current <= (unsigned char){end}) {{
        lexer_state->offset += 1;
        return true;
    }}

    return false;
}}
"#,
                    id = id,
                    start = range.start(),
                    end = range.end()
                )
                .unwrap();
            }

            OptionAst::Char(ch) => {
                // Important: in your QBE you used a byte compare (w {char}), so we treat it as a byte here too.
                // If OptionAst::Char stores a Rust `char`, you probably want to emit `(*ch as u32)` or encode to UTF-8.
                // Since you said you're ignoring UTF-8 complications, we assume it's already a 0..=255 value.
                writeln!(
                    f,
                    r#"
/* RegexChar */
static bool lex_{id}(LexerState *lexer_state) {{
    if (lexer_state->offset >= lexer_state->len) {{
        return false; /* EOF */
    }}

    if ((unsigned char)lexer_state->data[lexer_state->offset] == (unsigned char){byte}) {{
        lexer_state->offset += 1;
        return true;
    }}

    return false;
}}
"#,
                    id = id,
                    byte = *ch
                )
                .unwrap();
            }

            OptionAst::Regex(regex_ast) => {
                let inner_id = regex_ast.build(state, f);
                writeln!(
                    f,
                    r#"
/* RegexRegexOption */
static bool lex_{id}(LexerState *lexer_state) {{
    return lex_{inner}(lexer_state);
}}
"#,
                    id = id,
                    inner = inner_id
                )
                .unwrap();
            }
        }

        id
    }
}
