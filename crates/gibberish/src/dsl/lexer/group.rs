use std::fmt::Write;

use crate::dsl::{lexer::build::LexerBuilderState, regex::RegexAst};

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
