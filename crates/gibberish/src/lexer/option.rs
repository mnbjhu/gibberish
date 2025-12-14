use std::{
    fmt::{Display, Write},
    ops::Range,
};

use crate::lexer::{RegexAst, build::LexerBuilderState, parse_special};

#[derive(Debug)]
pub enum OptionAst {
    Range(Range<u8>),
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
                return Some(OptionAst::Range(char as u8..end as u8));
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
            OptionAst::Range(range) => write!(f, "{}-{}", range.start as char, range.end as char),
            OptionAst::Char(c) => write!(f, "{}", *c as char),
            OptionAst::Regex(_) => todo!(),
        }
    }
}

impl OptionAst {
    pub fn build(&self, state: &mut LexerBuilderState, f: &mut impl Write) -> usize {
        let id = state.id();
        match self {
            OptionAst::Range(range) => write!(
                f,
                "
# RegexRange
function w $lex_{id}(l %lexer_state) {{
@start
    %len_ptr =l add %lexer_state, 8
    %len =l loadl %len_ptr
    %ptr =l loadl %lexer_state
    %offset_ptr =l add %lexer_state, 16
    %offset =l loadl %offset_ptr
    %is_eof =w ceql %offset, %len
    jnz %is_eof, @fail, @cmp
@cmp
    %index =l add %offset, %ptr
    %current =w loadub %index
    %lower =w cugew %current, {start}
    %upper =w culew %current, {end}
    %res =w and %lower, %upper
    jnz %res, @pass, @fail
@pass
    call $inc_offset(l %lexer_state)
    ret 1
@fail
    ret 0
}}
",
                start = range.start,
                end = range.end
            )
            .unwrap(),
            OptionAst::Char(char) => write!(
                f,
                "
# RegexChar
function w $lex_{id}(l %lexer_state) {{
@start
    %res =w call $cmp_current(l %lexer_state, w {char})
    jnz %res, @pass, @fail
@pass
    call $inc_offset(l %lexer_state)
    ret 1
@fail
    ret 0
}}
"
            )
            .unwrap(),
            OptionAst::Regex(regex_ast) => {
                let inner_id = regex_ast.build(state, f);
                write!(
                    f,
                    "
# RegexRegexOption
function w $lex_{id}(l %offset_ptr) {{
@start
    %res =w call $lex_{inner_id}(l %offset_ptr)
    ret %res
}}
"
                )
                .unwrap()
            }
        }
        id
    }
}
