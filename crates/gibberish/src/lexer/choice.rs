use std::fmt::Write;

use crate::lexer::{
    RegexAst,
    build::LexerBuilderState,
    option::{OptionAst, parse_option},
};

pub fn parse_choice<'a>(regex: &'a str, offset: &mut usize) -> Option<RegexAst<'a>> {
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

pub fn build_choice_regex<'a>(
    state: &mut LexerBuilderState,
    f: &mut impl Write,
    options: &[OptionAst<'a>],
) -> usize {
    let id = state.id();
    let parts = options
        .iter()
        .map(|it| it.build(state, f))
        .collect::<Vec<_>>();
    write!(
        f,
        "
# RegexChoice
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

pub fn build_negated_chocie_regex<'a>(
    state: &mut LexerBuilderState,
    f: &mut impl Write,
    options: &[OptionAst<'a>],
) -> usize {
    let id = state.id();
    let parts = options
        .iter()
        .map(|it| it.build(state, f))
        .collect::<Vec<_>>();
    write!(
        f,
        "
# RegexNegatedChoice
function l $lex_{id} (l %ptr, l %len) {{
@start
    %start =l loadl $offset_ptr
    jmp @option_0
"
    )
    .unwrap();
    let end = parts.len() - 1;
    for (index, part) in parts.iter().enumerate() {
        let next = if index == end {
            "pass"
        } else {
            &format!("option_{}", index + 1)
        };
        write!(
            f,
            "
@option_{index}
    %res =w call $lex_{part}(l %ptr, l %len)
    jnz %res, @fail, @{next}
"
        )
        .unwrap()
    }
    write!(
        f,
        "
@pass
    %offset =l loadl $offset_ptr
    %is_eof =l ceql %offset, %len
    jnz %is_eof, @eof, @inc
@inc
    call $inc_offset()
    ret 1
@eof
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
