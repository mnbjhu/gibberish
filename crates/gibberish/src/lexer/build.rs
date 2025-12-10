use std::fmt::Write;

use crate::lexer::{
    RegexAst,
    choice::{build_choice_regex, build_negated_chocie_regex},
    exact::build_exact_regex,
    group::build_group_regex,
    seq::build_seq_regex,
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

impl RegexAst {
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
            RegexAst::Group { options, capture } => build_group_regex(state, f, options, *capture),
            RegexAst::Rep0(regex_ast) => {
                let inner = regex_ast.build(state, f);
                let id = state.id();
                write!(
                    f,
                    "
# Rep0Regex
function w $lex_{id} (l %lexer_state) {{
@start
    jmp @loop
@check_eof
    %len_ptr =l add %lexer_state, 8
    %len =l loadl %len_ptr
    %offset_ptr =l add %lexer_state, 16
    %offset =l loadl %offset_ptr
    %eof =w ceql %offset, %len
    jnz %eof, @pass, @loop
@loop
    %res =w call $lex_{inner}(l %lexer_state)
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
# Rep0Regex
function w $lex_{id} (l %lexer_state) {{
@start
    %len_ptr =l add %lexer_state, 8
    %len =l loadl %len_ptr
    %offset_ptr =l add %lexer_state, 16
    %offset =l loadl %offset_ptr
    %eof =w ceql %offset, %len
    jnz %eof, @fail, @check_start
@check_start
    %res =w call $lex_{inner}(l %lexer_state)
    jnz %res, @check_eof, @fail
@check_eof
    %offset =l loadl %offset_ptr
    %eof =w ceql %offset, %len
    jnz %eof, @pass, @loop
@loop
    %res =w call $lex_{inner}(l %lexer_state)
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

function w $lex_{id} (l %lexer_state) {{
@start
    %ptr =l loadl %lexer_state
    %offset_ptr =l add %lexer_state, 16
    %offset =l loadl %offset_ptr
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
    call $inc_offset(l %lexer_state)
    ret 1
}}
"
                )
                .unwrap();
                id
            }
            RegexAst::Any => {
                let id = state.id();
                write!(
                    f,
                    "

function w $lex_{id} (l %lexer_state) {{
@pass
    call $inc_offset(l %lexer_state)
    ret 1
}}
"
                )
                .unwrap();
                id
            }
            RegexAst::Error => panic!("Shouldn't exist in this phase of compile"),
        }
    }
}

pub fn build_lexer_qbe(lexer: &[(String, RegexAst)], f: &mut impl Write) {
    let mut state = LexerBuilderState::new();
    for (name, regex) in lexer {
        build_token_parser(name, regex, &mut state, f)
    }
    create_lex_function(f, lexer);
    let names = lexer.iter().map(|(it, _)| it.as_str()).collect::<Vec<_>>();
    create_name_function(f, "token", &names);
}

pub fn create_name_function(f: &mut impl Write, kind: &str, names: &[&str]) {
    for name in names {
        write!(
            f,
            "
data ${name}_{kind}_name = {{ b \"{name}\", b 0 }}
data ${name}_{kind}_name_len = {{ l {name_len} }}
",
            name_len = name.len()
        )
        .unwrap();
    }
    write!(
        f,
        "
data $err_{kind}_name = {{ b \"{kind}_error\", b 0}}


export function :str_slice ${kind}_name(w %kind) {{"
    )
    .unwrap();
    for (index, name) in names.iter().enumerate() {
        let next = if index == names.len() - 1 {
            "err"
        } else {
            names[index + 1]
        };
        write!(
            f,
            "
@{name}
    %ptr =l copy ${name}_{kind}_name
    %len =l copy {name_len}
    %res =w ceqw %kind, {index}
    jnz %res, @found, @{next}
",
            name_len = name.len()
        )
        .unwrap();
    }
    write!(
        f,
        "
@err
    %ptr =l copy $err_{kind}_name
    %len =l copy 5
    jmp @found
@found
    %slice =l alloc8 16
    %len_ptr =l add %slice, 8
    
    storel %ptr, %slice
    storel %len, %len_ptr
    ret %slice
}}"
    )
    .unwrap();
}
fn create_lex_function(f: &mut impl Write, names: &[(String, RegexAst)]) {
    write!(
        f,
        "
export function :vec $lex(l %ptr, l %len) {{
@start
    %lexer_state =l alloc8 32

    %len_ptr =l add %lexer_state, 8
    %offset_ptr =l add %lexer_state, 16
    %group_end_ptr =l add %lexer_state, 24

    storel %ptr, %lexer_state
    storel %len, %len_ptr
    storel 0, %offset_ptr
    storel 0, %group_end_ptr

    %tokens =:vec call $new_vec(l 24)
    %last_was_error =w copy 0
    %total_offset =l copy 0
    jmp @loop
@loop
    jnz %len, @check_{first}, @end
",
        first = names.first().unwrap().0
    )
    .unwrap();
    let last = names.len() - 1;
    for (index, (name, _)) in names.iter().enumerate() {
        let next = if index == last {
            "fail"
        } else {
            &format!("check_{}", names[index + 1].0)
        };
        write!(
            f,
            "
@check_{name}
    storel 0, %group_end_ptr
    %res =l call $lex_{name}(l %lexer_state)
    jnz %res, @check_overflow_{name}, @{next}
@check_overflow_{name}
    %overflow =l cugtl %res, %len
    jnz %overflow, @end, @bump_{name}
@bump_{name}
    %end =l add %total_offset, %res
    %tok =:token call $new_token(l {index}, l %total_offset, l %end)
    call $push(l %tokens, l 24, l %tok)
    %total_offset =l copy %end
    jmp @finish_loop

"
        )
        .unwrap();
    }
    write!(
        f,
        "
@finish_loop
    %ptr =l add %ptr, %res
    %len =l sub %len, %res
    storel %ptr, %lexer_state
    storel %len, %len_ptr
    storel 0, %offset_ptr
    storel 0, %group_end_ptr

    %last_was_error =w copy 0
    jmp @loop
@fail
    jnz %last_was_error, @fail_again, @fail_first
@fail_first
    %end =l add %total_offset, 1
    %tok =:token call $new_token(l {error_index}, l %total_offset, l %end)
    call $push(l %tokens, l 24, l %tok)
    jmp @fail_finish
@fail_again
    %end =l add %total_offset, 1
    %last_ptr =l call $last(l %tokens, l 24)
    %last_end_ptr =l add %last_ptr, 16
    %last_end =l loadl %last_end_ptr
    %new_end =l add %last_end, 1
    storel %new_end, %last_end_ptr
    jmp @fail_finish

@fail_finish
    %total_offset =l copy %end
    %ptr =l add %ptr, 1
    %len =l sub %len, 1
    storel 0, %offset_ptr
    storel 0, %group_end_ptr
    %last_was_error =w copy 1
    jmp @loop
    
@end
    ret %tokens
}}
",
        error_index = names.len()
    )
    .unwrap()
}

pub fn build_token_parser(
    name: &str,
    regex: &RegexAst,
    state: &mut LexerBuilderState,
    f: &mut impl Write,
) {
    let id = regex.build(state, f);
    write!(
        f,
        "
function l $lex_{name} (l %lexer_state) {{
@start
    %res =w call $lex_{id}(l %lexer_state)
    jnz %res, @pass, @fail
@pass
    %group_ptr =l add %lexer_state, 24
    %group =l loadl %group_ptr
    jnz %group, @ret_group, @ret_all
@ret_group
    ret %group
@ret_all
    %offset_ptr =l add %lexer_state, 16
    %offset =l loadl %offset_ptr
    ret %offset
@fail
    ret 0
}}
",
    )
    .unwrap();
}
