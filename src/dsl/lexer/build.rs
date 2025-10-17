use std::fmt::Write;

use crate::dsl::{
    ast::{
        RootAst,
        stmt::{StmtAst, keyword::KeywordDefAst, token::TokenDefAst},
    },
    lexer::{
        choice::{build_choice_regex, build_negated_chocie_regex},
        exact::build_exact_regex,
        group::build_group_regex,
        seq::build_seq_regex,
    },
    regex::{OptionAst, RegexAst, parse_seq},
};

pub struct LexerBuilderState {
    pub counter: usize,
}

impl LexerBuilderState {
    pub fn new() -> LexerBuilderState {
        LexerBuilderState { counter: 0 }
    }

    pub fn id(&mut self) -> usize {
        let res = self.counter;
        self.counter += 1;
        res
    }
}

impl<'a> RegexAst<'a> {
    pub fn build(&self, state: &mut LexerBuilderState, f: &mut impl Write) -> usize {
        match self {
            RegexAst::Exact(text) => build_exact_regex(f, state, text),
            RegexAst::Seq(regex_asts) => build_seq_regex(state, f, regex_asts),
            RegexAst::Choice { negate, options } => {
                if *negate {
                    build_negated_chocie_regex(state, f, options)
                } else {
                    build_choice_regex(state, f, options)
                }
            }
            RegexAst::Group { options } => build_group_regex(state, f, options),
            RegexAst::Rep0(regex_ast) => {
                let inner = regex_ast.build(state, f);
                let id = state.id();
                write!(
                    f,
                    "
function w $lex_{id} (l %ptr, l %len) {{
@start
    jmp @loop
@check_eof
    %offset =l loadl $offset_ptr
    %eof =w ceql %offset, %len
    jnz %eof, @pass, @loop
@loop
    %res =w call $lex_{inner}(l %ptr, l %len)
    jnz %res, @check_eof, @pass
@pass
    ret 1
}}
"
                )
                .unwrap();
                id
            }
            RegexAst::Rep1(regex_ast) => {
                let inner = regex_ast.build(state, f);
                let id = state.id();
                write!(
                    f,
                    "

function w $lex_{id} (l %ptr, l %len) {{
@start
    %offset =l loadl $offset_ptr
    %eof =w ceql %offset, %len
    jnz %eof, @fail, @check_start
@check_start
    %res =w call $lex_{inner}(l %ptr, l %len)
    jnz %res, @check_eof, @fail
@check_eof
    %offset =l loadl $offset_ptr
    %eof =w ceql %offset, %len
    jnz %eof, @pass, @loop
@loop
    %res =w call $lex_{inner}(l %ptr, l %len)
    jnz %res, @check_eof, @pass
@pass
    ret 1
@fail
    ret 0
}}
"
                )
                .unwrap();
                id
            }
            RegexAst::Whitepace => {
                let id = state.id();
                write!(
                    f,
                    "

function w $lex_{id} (l %ptr, l %len) {{
@start
    %offset =l loadl $offset_ptr
    %index =l add %offset, %ptr
    %current =w loadub %index
    %space =w ceqw %current, 32
    %lower =w cugew %current, 9
    %upper =w culew %current, 13
    %res =w and %lower, %upper
    %res =w or %res, %space
    jnz %res, @pass, @fail
@fail
    ret 0
@pass
    call $inc_offset()
    ret 1
}}
"
                )
                .unwrap();
                id
            }
            RegexAst::Any => todo!(),
        }
    }
}

pub fn build_lexer_qbe<'a>(ast: RootAst<'a>, src: &str, filename: &str, f: &mut impl Write) {
    write!(
        f,
        "
data $tokens_ptr = {{ l 0 }}
data $tokens_len = {{ l 0 }}
data $tokens_cap = {{ l 0 }}

data $fmt = {{ b \"{{ token: %d, start: %d, end: %d }}\\n\", b 0 }}

function w $print_tokens() {{
@start
    %len =l loadl $tokens_len
    %token_ptr =l loadl $tokens_ptr
    %finish_offset =l mul %len, 24
    %finish_offset =l add %token_ptr, %finish_offset
    jmp @loop
@loop
    %at_end =l ceql %finish_offset, %token_ptr
    jnz %at_end, @end, @inc
@inc
    %start_ptr =l add %token_ptr, 8
    %end_ptr =l add %token_ptr, 16
    %tok =l loadl %token_ptr
    %start =l loadl %start_ptr
    %end =l loadl %end_ptr
    %token_ptr =l add %token_ptr, 24
    call $printf(l $fmt, l %tok, l %start, l %end)
    jmp @loop
@end
    ret 1
}}

function w $create_tokens() {{
@start
    storel 4, $tokens_cap
    storel 0, $tokens_len
    %ptr =l call $malloc(l 96)
    storel %ptr, $tokens_ptr
    ret 1
}}

function w $push_token(l %tok, l %start, l %end) {{
@start
    %cap =l loadl $tokens_cap
    %len =l loadl $tokens_len
    %ptr =l loadl $tokens_ptr
    %full =w ceql %len, %cap
    jnz %full, @alloc, @push
@alloc
    %cap =l mul %cap, 4
    %size =l mul %cap, 24
    %new_ptr =l call $malloc(l %size)
    storel %cap, $tokens_cap
    storel %new_ptr, $tokens_ptr

    %size =l mul %len, 24
    call $memcpy(l %new_ptr, l %ptr, l %size)
    call $free(l %ptr)
    %ptr =l copy %new_ptr
    jmp @push
@push
    %offset =l mul %len, 24
    %token_ptr =l add %offset, %ptr
    %start_ptr =l add %token_ptr, 8
    %end_ptr =l add %token_ptr, 16
    %len =l add %len, 1
    storel %len, $tokens_len
    storel %tok, %token_ptr
    storel %start, %start_ptr
    storel %end, %end_ptr
    ret 1
}}

data $error_token = {{ b \"ERROR\\n\", b 0 }}
data $offset_ptr = {{ l 0 }}
data $group_end = {{ l 0 }}

function w $cmp_current(l %ptr, l %len, w %char) {{
@start
    %offset =l loadl $offset_ptr
    %actual_offset =l add %ptr, %offset
    %current =w loadub %actual_offset
    %res =w ceqw %current, %char
    ret %res
}}

function w $inc_offset() {{
@start
    %offset =l loadl $offset_ptr
    %offset =l add %offset, 1
    storel %offset, $offset_ptr
    ret 0
}}

",
    )
    .unwrap();
    let mut state = LexerBuilderState::new();
    let mut names = vec![];
    for stmt in ast.iter() {
        match stmt {
            StmtAst::Token(token_def_ast) => {
                let name = &token_def_ast.name().text;
                write!(
                    f,
                    "
data $lex_{name}_text = {{ b \"{name} %d\\n\", b 0 }}
"
                )
                .unwrap();
                token_def_ast.build_qbe(&mut state, f);
                names.push(name);
            }
            StmtAst::Keyword(kw_ast) => {
                let name = &kw_ast.name().text;
                write!(
                    f,
                    "
data $lex_{name}_text = {{ b \"{name} %d\\n\", b 0 }}
"
                )
                .unwrap();
                kw_ast.build_qbe(&mut state, f);
                names.push(name);
            }
            _ => (),
        };
    }
    println!("len: {}", names.len());
    write!(
        f,
        "
export function w $lex(l %ptr, l %len) {{
@start
    %total_offset =l copy 0
    jmp @loop
@loop
    %offset =l loadl $offset_ptr
    %eof =w ceql %offset, %len
    jnz %eof, @end, @check_{first}
",
        first = names.first().unwrap()
    )
    .unwrap();
    let last = names.len() - 1;
    for (index, name) in names.iter().enumerate() {
        let next = if index == last {
            "fail"
        } else {
            &format!("check_{}", names[index + 1])
        };
        write!(
            f,
            "
@check_{name}
    %res =l call $lex_{name}(l %ptr, l %len)
    jnz %res, @bump_{name}, @{next}
@bump_{name}
    call $printf(l $lex_{name}_text, l %res)
    %offset =l loadl $offset_ptr
    %end =l add %total_offset, %offset
    call $push_token(l {index}, l %total_offset, l %end)
    %total_offset =l copy %end
    %ptr =l add %ptr, %res
    %len =l sub %len, %res
    storel 0, $offset_ptr
    storel 0, $group_end
    jmp @loop
"
        )
        .unwrap();
    }
    write!(
        f,
        "

@fail
    call $printf(l $error_token)
    %ptr =l add %ptr, 1
    %len =l sub %len, 1
    storel 0, $offset_ptr
    storel 0, $group_end
@end
    ret 0
}}
"
    )
    .unwrap()
}

impl<'a> TokenDefAst<'a> {
    pub fn build_qbe(&self, state: &mut LexerBuilderState, f: &mut impl Write) {
        let value = self.value().unwrap();
        let mut text = value.text.clone();
        text.remove(0);
        text.pop();
        text = text.replace("\\\\", "\\");
        text = text.replace("\\\"", "\"");
        text = text.replace("\\n", "\n");
        text = text.replace("\\t", "\t");
        let Some(regex) = parse_seq(&text, &mut 0) else {
            panic!("Failed to parse regex {text}");
        };
        build_token_parser(&self.name().text, &regex, state, f)
    }
}

impl<'a> KeywordDefAst<'a> {
    pub fn build_qbe(&self, state: &mut LexerBuilderState, f: &mut impl Write) {
        let value = self.name();
        let text = &value.text;
        let regex = RegexAst::Seq(vec![
            RegexAst::Group {
                options: vec![RegexAst::Exact(text)],
            },
            RegexAst::Choice {
                negate: true,
                options: vec![
                    OptionAst::Range('a' as u8..'z' as u8),
                    OptionAst::Range('A' as u8..'Z' as u8),
                    OptionAst::Range('0' as u8..'9' as u8),
                    OptionAst::Char('_' as u8),
                ],
            },
        ]);
        build_token_parser(&self.name().text, &regex, state, f)
    }
}

pub fn build_token_parser<'a>(
    name: &str,
    regex: &RegexAst<'a>,
    state: &mut LexerBuilderState,
    f: &mut impl Write,
) {
    let id = regex.build(state, f);
    write!(
        f,
        "
function l $lex_{name} (l %ptr, l %len) {{
@start
    %res =w call $lex_{id}(l %ptr, l %len)
    jnz %res, @pass, @fail
@pass
    %group =l loadl $group_end
    jnz %group, @ret_group, @ret_all
@ret_group
    ret %group
@ret_all
    %offset =l loadl $offset_ptr
    ret %offset
@fail
    ret 0
}}
",
    )
    .unwrap();
}
