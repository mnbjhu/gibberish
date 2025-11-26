use std::fmt::Write;

use crate::dsl::{lexer::build::LexerBuilderState, regex::RegexAst};

pub fn build_seq_regex<'a>(
    state: &mut LexerBuilderState,
    f: &mut impl Write,
    parts: &[RegexAst<'a>],
) -> usize {
    let id = state.id();
    let parts = parts
        .iter()
        .map(|it| it.build(state, f))
        .collect::<Vec<_>>();
    write!(
        f,
        "
# RegexSeq
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
            "pass"
        } else {
            &format!("part_{}", index + 1)
        };
        write!(
            f,
            "
@part_{index}
    %res =w call $lex_{part}(l %ptr, l %len)
    jnz %res, @{next}, @fail
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
