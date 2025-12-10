use std::fmt::Write;

use thiserror::Error;

use crate::lexer::{RegexAst, build::LexerBuilderState, parse_regex};

#[derive(Debug, Error)]
pub enum RegexError {}

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
    let parts = parts
        .iter()
        .map(|it| it.build(state, f))
        .collect::<Vec<_>>();
    write!(
        f,
        "
# RegexSeq
function l $lex_{id} (l %lexer_state) {{
@start
    %offset_ptr =l add %lexer_state, 16
    %start =l loadl %offset_ptr
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
    %res =w call $lex_{part}(l %lexer_state)
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
    storel %start, %offset_ptr
    ret 0
}}
"
    )
    .unwrap();
    id
}
