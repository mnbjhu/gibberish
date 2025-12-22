use std::fmt::Write;

use crate::{
    ast::builder::ParserBuilder,
    lexer::build::build_lexer_c,
    parser::{Parser, skip::Skip},
};

pub fn build_parser_c(builder: &mut ParserBuilder, f: &mut impl Write) {
    build_lexer_c(&builder.lexer, f);
    build_default_state(builder, f);
    emit_parse_entry_c(builder, f);
}

fn emit_parse_entry_c(builder: &mut ParserBuilder, f: &mut impl Write) {
    if let Some(root) = builder.vars.iter().position(|it| it.0 == "root") {
        let mut inner = builder.vars[root].1.clone();
        let mut skipped_calls = String::new();
        while let Parser::Skip(Skip { token, inner: i }) = inner {
            inner = *i;
            let tok_id = builder.get_token_id(&token);
            writeln!(
                &mut skipped_calls,
                "        skip(&state, (uint32_t){tok_id});"
            )
            .unwrap();
        }

        let p = builder.vars[root].1.clone();
        p.predefine(builder, f);
        let inner_id = p.build(builder, f);
        writeln!(
            f,
            r#"
enum {{ ROOT_GROUP_ID = {root} }};

EXPORT Node parse(char *ptr, size_t len) {{
    ParserState state = default_state(ptr, len);

    for (;;) {{
{skipped_calls}
        size_t res = parse_{inner_id}(&state, 0);

        if (res != 0) {{
            /* res == 2 => missing expected */
            if (res == 2) {{
                ExpectedVec expected = expected_{inner_id}();
                missing(&state, expected);
            }} else {{
                bump_err(&state);
                continue;
            }}
        }}

        break;
    }}

    for (;;) {{
        if (state.offset >= state.tokens.len) {{
            break;
        }}

        uint32_t k = current_kind(&state);
        if (skipped_vec_contains(&state.skipped, k)) {{
            bump_skipped(&state);
            continue;
        }}

        bump_err(&state);
    }}

    if (state.stack.len != 1) {{
        abort();
    }}

    Node out;
    bool ok = node_vec_pop(&state.stack, &out);
    if (!ok) {{
        abort();
    }}

    return out;
}}
"#,
            root = root,
            skipped_calls = skipped_calls,
            inner_id = inner_id
        )
        .unwrap();
    } else {
        let root_id = builder.vars.len() + 1;
        writeln!(
            f,
            r#"
enum {{ ROOT_GROUP_ID = {root_id} }};

Node parse(char *ptr, size_t len) {{
    ParserState state = default_state(ptr, len);

    while (state.offset < state.tokens.len) {{
        bump_err(&state);
    }}

    if (state.stack.len != 1) {{
        abort();
    }}

    Node out;
    bool ok = node_vec_pop(&state.stack, &out);
    if (!ok) {{
        abort();
    }}
    return out;
}}
"#,
        )
        .unwrap();
    }
}

pub fn build_default_state(builder: &ParserBuilder, f: &mut impl Write) {
    let root_id = builder
        .vars
        .iter()
        .position(|(name, _)| name == "root")
        .unwrap();

    writeln!(
        f,
        r#"
ParserState default_state(char *ptr, size_t len) {{
    Node root = new_group_node({root_id});

    NodeVec stack = node_vec_new();
    node_vec_push(&stack, root);

    TokenVec tokens = lex(ptr, len);

    return (ParserState){{
        .tokens  = tokens,
        .stack   = stack,
        .offset  = 0,
        .breaks  = break_stack_new(),
        .skipped = skipped_vec_new(),
    }};
}}
"#,
    )
    .unwrap();
}
