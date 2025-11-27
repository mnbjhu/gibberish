use std::fmt::{Display, Write};

use crate::dsl::{lexer::build::LexerBuilderState, regex::OptionAst};

impl<'a> Display for OptionAst<'a> {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            OptionAst::Range(range) => write!(f, "{}-{}", range.start as char, range.end as char),
            OptionAst::Char(c) => write!(f, "{}", *c as char),
            OptionAst::Regex(_) => todo!(),
        }
    }
}

impl<'a> OptionAst<'a> {
    pub fn build(&self, state: &mut LexerBuilderState, f: &mut impl Write) -> usize {
        let id = state.id();
        match self {
            OptionAst::Range(range) => write!(
                f,
                "
# RegexRange
function w $lex_{id}(l %ptr, l %len) {{
@start
    %offset =l loadl $offset_ptr
    %index =l add %offset, %ptr
    %current =w loadub %index
    %lower =w cugew %current, {start}
    %upper =w culew %current, {end}
    %res =w and %lower, %upper
    jnz %res, @pass, @fail
@pass
    call $inc_offset()
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
function w $lex_{id}(l %ptr, l %len) {{
@start
    %res =w call $cmp_current(l %ptr, l %len, w {char})
    jnz %res, @pass, @fail
@pass
    call $inc_offset()
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
function w $lex_{id}(l %ptr, l %len) {{
@start
    %res =w call $lex_{inner_id}(l %ptr, l %len)
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
