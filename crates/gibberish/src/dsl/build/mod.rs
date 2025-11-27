use std::fmt::Write;

use gibberish_core::err::Expected;

use crate::{
    api::{Parser, ptr::ParserIndex},
    dsl::{lexer::build::build_lexer_qbe, parser::ParserBuilder},
};

pub mod choice;
pub mod delim_by;
pub mod fold_once;
pub mod just;
pub mod named;
pub mod optional;
pub mod rep0;
pub mod sep_by;
pub mod seq;
pub mod skip;

pub fn build_parser_qbe(parser: &ParserIndex, builder: &ParserBuilder, f: &mut impl Write) {
    build_lexer_qbe(&builder.lexer, f);
    build_parse_by_id(builder, f);
    for (index, parser) in builder.cache.parsers.iter().enumerate() {
        parser.build_parse(index, f);
        parser.build_peak(index, f);
        parser.build_expected(index, f, builder);
    }

    write!(
        f,
        "
data $root_group_id = {{ w {root} }}

export function w $parse(l %state_ptr) {{
@start
    jmp @loop
@loop
    %res =l call $parse_{inner}(l %state_ptr, w 1)
    jnz %res, @check_eof, @end
@check_eof
    %is_eof =l ceql %res, 2
    jnz %is_eof, @end, @bump_err
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
",
        inner = parser.index,
        root = builder.vars.len()
    )
    .unwrap()
}

impl ParserQBEBuilder for Parser {
    fn build_parse(&self, id: usize, f: &mut impl Write) {
        match self {
            Parser::Just(just) => just.build_parse(id, f),
            Parser::Choice(choice) => choice.build_parse(id, f),
            Parser::Seq(seq) => seq.build_parse(id, f),
            Parser::Sep(sep) => sep.build_parse(id, f),
            Parser::Delim(delim) => delim.build_parse(id, f),
            Parser::Named(named) => named.build_parse(id, f),
            Parser::Skip(skip) => skip.build_parse(id, f),
            Parser::UnSkip(_) => todo!(),
            Parser::Optional(optional) => optional.build_parse(id, f),
            Parser::FoldOnce(fold_once) => fold_once.build_parse(id, f),
            Parser::Repeated(repeated) => repeated.build_parse(id, f),
            Parser::Empty => todo!(),
        }
    }

    fn build_peak(&self, id: usize, f: &mut impl Write) {
        match self {
            Parser::Just(just) => just.build_peak(id, f),
            Parser::Choice(choice) => choice.build_peak(id, f),
            Parser::Seq(seq) => seq.build_peak(id, f),
            Parser::Sep(sep) => sep.build_peak(id, f),
            Parser::Delim(delim) => delim.build_peak(id, f),
            Parser::Named(named) => named.build_peak(id, f),
            Parser::Skip(skip) => skip.build_peak(id, f),
            Parser::UnSkip(_) => todo!(),
            Parser::Optional(optional) => optional.build_peak(id, f),
            Parser::FoldOnce(fold_once) => fold_once.build_peak(id, f),
            Parser::Repeated(repeated) => repeated.build_peak(id, f),
            Parser::Empty => todo!(),
        }
    }
}

impl Parser {
    fn build_expected(&self, id: usize, f: &mut impl Write, builder: &ParserBuilder) {
        if let Parser::Optional(_) = self {
            write!(
                f,
                "
function :vec $expected_{id}() {{
@start
    %res =l alloc8 24
    storel 0, %res
    ret %res
}}
",
            )
            .unwrap();
            return;
        }
        let expected = self.expected(&builder.cache);
        write!(f, "\ndata $expected_{id}_data = {{").unwrap();
        expected.iter().enumerate().for_each(|(index, it)| {
            if index != 0 {
                write!(f, ",").unwrap();
            }
            let (kind, id) = match it {
                Expected::Token(id) => (0, id),
                Expected::Label(id) => (1, id),
                Expected::Group(id) => (2, id),
            };
            write!(f, "l {kind}, l {id}",).unwrap()
        });
        writeln!(f, "}}").unwrap();
        write!(
            f,
            "
function :vec $expected_{id}() {{
@start
    %ptr =l call $malloc(l {size})
    %res =l alloc8 24
    call $memcpy(l %ptr, l $expected_{id}_data, l {size})
    %len_ptr =l add %res, 8
    %cap_ptr =l add %res, 16
    
    storel %ptr, %res
    storel {len}, %len_ptr
    storel {len}, %cap_ptr
    ret %res
}}
",
            size = expected.len() * 16,
            len = expected.len()
        )
        .unwrap();
    }
}

pub trait ParserQBEBuilder {
    fn build_parse(&self, id: usize, f: &mut impl Write);
    fn build_peak(&self, id: usize, f: &mut impl Write);
}

pub fn build_parse_by_id(builder: &ParserBuilder, f: &mut impl Write) {
    write!(
        f,
        "
function l $peak_by_id(l %state_ptr, l %offset, w %recover, l %id) {{
"
    )
    .unwrap();

    for (index, _) in builder.cache.parsers.iter().enumerate() {
        let next = if index + 1 == builder.cache.parsers.len() {
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
