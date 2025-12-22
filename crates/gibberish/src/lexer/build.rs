use std::fmt::Write;

use crate::lexer::{
    RegexAst,
    choice::{build_choice_regex, build_negated_choice_regex},
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
                    build_negated_choice_regex(state, f, options)
                } else {
                    build_choice_regex(state, f, options)
                }
            }
            RegexAst::Group { options, capture } => build_group_regex(state, f, options, *capture),

            RegexAst::Rep0(regex_ast) => {
                let inner = regex_ast.build(state, f);
                let id = state.id();

                // Rep0: always succeeds; repeatedly applies inner until it fails or EOF.
                // Also guards against infinite loops if inner succeeds without consuming.
                writeln!(
                    f,
                    r#"
/* Rep0Regex */
static bool lex_{id}(LexerState *lexer_state) {{
    for (;;) {{
        size_t before = lexer_state->offset;
        if (!lex_{inner}(lexer_state)) {{
            break;
        }}
        if (lexer_state->offset == before) {{
            break;
        }}
        if (lexer_state->offset >= lexer_state->len) {{
            break;
        }}
    }}
    return true;
}}
"#,
                )
                .unwrap();
                id
            }

            RegexAst::Rep1(regex_ast) => {
                let inner = regex_ast.build(state, f);
                let id = state.id();

                writeln!(
                    f,
                    r#"
/* Rep1Regex */
static bool lex_{id}(LexerState *lexer_state) {{
    size_t start = lexer_state->offset;

    if (lexer_state->offset >= lexer_state->len) {{
        return false;
    }}
    if (!lex_{inner}(lexer_state)) {{
        lexer_state->offset = start;
        return false;
    }}

    for (;;) {{
        size_t before = lexer_state->offset;
        if (!lex_{inner}(lexer_state)) {{
            break;
        }}
        if (lexer_state->offset == before) {{
            break;
        }}
        if (lexer_state->offset >= lexer_state->len) {{
            break;
        }}
    }}

    return true;
}}
"#,
                )
                .unwrap();
                id
            }

            RegexAst::Whitepace => {
                let id = state.id();

                // Matches: space (32) or \t..\r (9..13)
                writeln!(
                    f,
                    r#"
/* Whitespace */
static bool lex_{id}(LexerState *lexer_state) {{
    if (lexer_state->offset >= lexer_state->len) {{
        return false;
    }}

    unsigned char c = (unsigned char)lexer_state->data[lexer_state->offset];
    bool is_space = (c == 32);
    bool is_ctrl_ws = (c >= 9 && c <= 13);

    if (is_space || is_ctrl_ws) {{
        lexer_state->offset += 1;
        return true;
    }}

    return false;
}}
"#,
                )
                .unwrap();
                id
            }

            RegexAst::Any => {
                let id = state.id();

                // Consumes one byte if not EOF.
                writeln!(
                    f,
                    r#"
/* Any */
static bool lex_{id}(LexerState *lexer_state) {{
    if (lexer_state->offset >= lexer_state->len) {{
        return false;
    }}
    lexer_state->offset += 1;
    return true;
}}
"#,
                )
                .unwrap();
                id
            }

            RegexAst::Error => panic!("Shouldn't exist in this phase of compile"),
        }
    }
}

pub fn build_lexer_c(lexer: &[(String, RegexAst)], f: &mut impl Write) {
    let mut state = LexerBuilderState::new();
    for (name, regex) in lexer {
        build_token_parser(name, regex, &mut state, f);
    }
    create_lex_function(f, lexer);
}

pub fn build_token_parser(
    name: &str,
    regex: &RegexAst,
    state: &mut LexerBuilderState,
    f: &mut impl Write,
) {
    let id = regex.build(state, f);

    writeln!(
        f,
        r#"
static size_t lex_{name}(LexerState *lexer_state) {{
    if (!lex_{id}(lexer_state)) {{
        return 0;
    }}

    if (lexer_state->group_offset != 0) {{
        return lexer_state->group_offset;
    }}
    return lexer_state->offset;
}}
"#,
    )
    .unwrap();
}

fn create_lex_function(f: &mut impl Write, names: &[(String, RegexAst)]) {
    let error_index = names.len();

    writeln!(
        f,
        r#"
EXPORT TokenVec lex(char *ptr, size_t len) {{
    LexerState st;
    st.data = ptr;
    st.len = len;
    st.offset = 0;
    st.group_offset = 0;

    TokenVec tokens = token_vec_new();

    bool last_was_error = false;
    size_t total_offset = 0;

    while (len != 0) {{
"#,
    )
    .unwrap();

    for (i, (name, _)) in names.iter().enumerate() {
        writeln!(
            f,
            r#"        st.group_offset = 0;
        size_t res_{i} = lex_{name}(&st);
        if (res_{i} != 0) {{
            if (res_{i} > len) {{
                break;
            }}

            size_t end = total_offset + res_{i};
            Token tok = (Token){{
                .kind = (uint32_t){i},
                ._padding = 0,
                .start = total_offset,
                .end = end,
            }};
            token_vec_push(&tokens, tok);

            total_offset = end;

            ptr += res_{i};
            len -= res_{i};

            st.data = ptr;
            st.len = len;
            st.offset = 0;
            st.group_offset = 0;

            last_was_error = false;
            continue;
        }}
"#,
        )
        .unwrap();
    }

    writeln!(
        f,
        r#"
        /* No token matched: produce/extend error token and consume one byte */
        if (!last_was_error) {{
            size_t end = total_offset + 1;
            Token tok = (Token){{
                .kind = (uint32_t){error_index},
                ._padding = 0,
                .start = total_offset,
                .end = end,
            }};
            token_vec_push(&tokens, tok);
        }} else {{
            /* Extend the previous error token by 1 */
            if (tokens.len != 0) {{
                tokens.data[tokens.len - 1].end += 1;
            }}
        }}

        total_offset += 1;
        ptr += 1;
        len -= 1;

        st.data = ptr;
        st.len = len;
        st.offset = 0;
        st.group_offset = 0;

        last_was_error = true;
    }}

    return tokens;
}}
"#,
    )
    .unwrap();
}

pub fn create_name_function(f: &mut impl Write, kind: &str, names: &[impl AsRef<str>]) {
    writeln!(f, "static const char *{kind}_names[] = {{",).unwrap();
    for name in names {
        writeln!(f, "    \"{}\",", name.as_ref()).unwrap();
    }
    writeln!(f, "    \"error\",").unwrap();
    writeln!(f, "}};\n").unwrap();
    writeln!(
        f,
        r#"
EXPORT const char *{kind}_name(uint32_t kind) {{
    if (kind < (uint32_t)(sizeof({kind}_names) / sizeof({kind}_names[0]))) {{
        return {kind}_names[kind];
    }}
    return "error";
}}
"#,
    )
    .unwrap();
}
