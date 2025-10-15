use std::fmt::Write;

use crate::dsl::{
    ast::{
        RootAst,
        stmt::{StmtAst, token::TokenDefAst},
    },
    lexer::{
        choice::{build_choice_regex, build_negated_chocie_regex},
        exact::build_exact_regex,
        seq::build_seq_regex,
    },
    regex::{OptionAst, RegexAst, parse_regex, parse_seq},
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
            RegexAst::Group { options } => todo!(),
            RegexAst::Rep0(regex_ast) => {
                let inner = regex_ast.build(state, f);
                let id = state.id();
                write!(
                    f,
                    "

function w $lex_{id} (l %ptr, l %len) {{
@start
    jmp @loop
@loop
    %res =w call $lex_{inner}(l %ptr, l %len)
    jnz %res, @loop, @pass
@pass
    %offset =l loadl $offset_ptr
    ret %offset
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
    %res =w call $lex_{inner}(l %ptr, l %len)
    jnz %res, @loop, @fail
@loop
    %res =w call $lex_{inner}(l %ptr, l %len)
    jnz %res, @loop, @pass
@pass
    %offset =l loadl $offset_ptr
    ret %offset
@fail
    ret 0
}}
"
                )
                .unwrap();
                id
            }
            RegexAst::Whitepace => todo!(),
            RegexAst::Any => todo!(),
        }
    }
}

pub fn build_lexer_qbe<'a>(ast: RootAst<'a>, src: &str, filename: &str, f: &mut impl Write) {
    write!(
        f,
        "
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
"
    )
    .unwrap();
    let mut state = LexerBuilderState::new();
    for stmt in ast.iter() {
        match stmt {
            StmtAst::Token(token_def_ast) => token_def_ast.build_qbe(&mut state, f),
            // StmtAst::Keyword(keyword_def_ast) => keyword_def_ast.build_qbe(f),
            _ => {}
        }
    }
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

        let id = parse_seq(&text, &mut 0).unwrap().build(state, f);
        write!(
            f,
            "
data $offset_ptr = {{ w 0 }}

export function l $lex_{} (l %ptr, l %len) {{
@start
    storel 0, $offset_ptr
    %res =w call $lex_{id}(l %ptr, l %len)
    jnz %res, @pass, @fail
@pass
    %offset =l loadl $offset_ptr
    ret %offset
@fail
    ret 0
}}
",
            self.name().text
        )
        .unwrap();
    }
}
