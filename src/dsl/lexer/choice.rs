use std::fmt::Write;

use crate::dsl::{lexer::build::LexerBuilderState, regex::OptionAst};

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
    call $inc_offset()
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
