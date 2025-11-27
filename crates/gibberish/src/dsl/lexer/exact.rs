use std::fmt::Write;

use crate::dsl::lexer::{RegexAst, build::LexerBuilderState};

pub fn parse_exact<'a>(regex: &'a str, offset: &mut usize) -> Option<RegexAst<'a>> {
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
        Some(RegexAst::Exact(&regex[start..*offset]))
    }
}

pub fn build_exact_regex(f: &mut impl Write, state: &mut LexerBuilderState, text: &str) -> usize {
    let id = state.id();
    write!(
        f,
        "
# Exact
function l $lex_{id} (l %ptr, l %len) {{
@start
    %start =l loadl $offset_ptr
    jmp @part_0
"
    )
    .unwrap();
    let end = text.len() - 1;
    for (index, part) in text.char_indices() {
        let next = if index == end {
            "pass"
        } else {
            &format!("part_{}", index + 1)
        };
        write!(
            f,
            "
@part_{index}
    %res =w call $cmp_current(l %ptr, l %len, w {})
    call $inc_offset()
    jnz %res, @{next}, @fail
",
            part as u8
        )
        .unwrap()
    }
    write!(
        f,
        "
@pass
    ret 1

@fail
    storel %start, $offset_ptr
    ret 0
}}
"
    )
    .unwrap();
    id
}
