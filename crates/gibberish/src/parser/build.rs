use std::fmt::Write;

use crate::{ast::builder::ParserBuilder, lexer::build::build_lexer_qbe};

pub fn build_parser_qbe(builder: &mut ParserBuilder, f: &mut impl Write) {
    build_lexer_qbe(&builder.lexer, f);

    if let Some(root) = builder.vars.iter().position(|it| it.0 == "root") {
        let inner = builder.vars[root].1.clone().build(builder, f);
        build_parse_by_id(builder, f);
        write!(
            f,
            "
data $root_group_id = {{ w {root} }}

export function w $parse(l %state_ptr) {{
@start
    jmp @loop
@loop
    %res =l call $parse_{inner}(l %state_ptr, w 1, l 0)
    jnz %res, @check_eof, @end
@check_eof
    %is_eof =l ceql %res, 2
    jnz %is_eof, @missing, @bump_err
@missing
    %expected =:vec call $expected_{inner}()
    call $missing(l %state_ptr, l %expected)
    jmp @end
@bump_err
    call $bump_err(l %state_ptr)
    jmp @loop
@end
    %is_eof =w call $is_eof(l %state_ptr)
    jnz %is_eof, @ret, @expected_eof
@expected_eof
    call $bump_err(l %state_ptr)
    jmp @end
@ret
    ret 1
}}
"
        )
        .unwrap()
    } else {
        write!(
            f,
            "
data $root_group_id = {{ w {root} }}

export function w $parse(l %state_ptr) {{
@start
    jmp @check_eof
@check_eof
    %is_eof =w call $is_eof(l %state_ptr)
    jnz %is_eof, @ret, @bump_err
@bump_err
    call $bump_err(l %state_ptr)
    jmp @check_eof
@ret
    ret 1
}}
",
            root = builder.vars.len() + 1
        )
        .unwrap()
    }
}

pub fn build_parse_by_id(builder: &ParserBuilder, f: &mut impl Write) {
    write!(
        f,
        "
function l $peak_by_id(l %state_ptr, l %offset, w %recover, l %id) {{
"
    )
    .unwrap();

    for index in 0..builder.built.len() {
        let next = if index + 1 == builder.built.len() {
            "@err".to_string()
        } else {
            format!("@check_{}", index + 1)
        };
        write!(
            f,
            "
@check_{index}
    %res =l ceql %id, {index}
    jnz %res, @do_{index}, {next}
@do_{index}
    %ret =l call $peak_{index}(l %state_ptr, l %offset, w %recover)
    ret %ret
"
        )
        .unwrap();
    }
    write!(
        f,
        "
@err
    ret 0
}}
"
    )
    .unwrap();
}
