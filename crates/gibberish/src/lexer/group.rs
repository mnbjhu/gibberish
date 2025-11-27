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

pub fn parse_group<'a>(regex: &'a str, offset: &mut usize) -> Option<RegexAst<'a>> {
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

pub fn build_group_regex<'a>(
    state: &mut LexerBuilderState,
    f: &mut impl Write,
    options: &[RegexAst<'a>],
    capture: bool,
) -> usize {
    let id = state.id();
    let parts = options
        .iter()
        .map(|it| it.build(state, f))
        .collect::<Vec<_>>();
    write!(
        f,
        "
# RegexGroup
function l $lex_{id} (l %ptr, l %len) {{
@start
    %start =l loadl $offset_ptr
    jmp @part_0
"
    )
    .unwrap();
    let end = parts.len() - 1;
    for (index, part) in parts.iter().enumerate() {
        let next = if index == end {
            "fail"
        } else {
            &format!("part_{}", index + 1)
        };
        write!(
            f,
            "
@part_{index}
    storel %start, $offset_ptr
    %res =w call $lex_{part}(l %ptr, l %len)
    jnz %res, @pass, @{next}
"
        )
        .unwrap()
    }
    write!(
        f,
        "
@pass
    %offset =l loadl $offset_ptr
"
    )
    .unwrap();
    if capture {
        write!(
            f,
            "
    storel %offset, $group_end
"
        )
        .unwrap();
    }
    write!(
        f,
        "
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
