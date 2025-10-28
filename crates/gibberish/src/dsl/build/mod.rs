use std::fmt::Write;

use crate::{
    api::{
        Parser,
        ptr::{ParserCache, ParserIndex},
    },
    dsl::lexer::RuntimeLang,
};

pub mod choice;
pub mod delim_by;
pub mod just;
pub mod named;
pub mod seq;
pub mod skip;

pub fn build_parser_qbe(
    parser: &ParserIndex<RuntimeLang>,
    cache: &ParserCache<RuntimeLang>,
    f: &mut impl Write,
) {
    build_parse_by_id(cache, f);
    for (index, parser) in cache.parsers.iter().enumerate() {
        parser.build_parse(index, f);
        parser.build_peak(index, f);
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
    ret 1
}}
",
        inner = parser.index,
        root = cache.lang.vars.len()
    )
    .unwrap()
}

impl ParserQBEBuilder for Parser<RuntimeLang> {
    fn build_parse(&self, id: usize, f: &mut impl Write) {
        match self {
            Parser::Just(just) => just.build_parse(id, f),
            Parser::TokSeq(tok_seq) => todo!(),
            Parser::Choice(choice) => choice.build_parse(id, f),
            Parser::Seq(seq) => seq.build_parse(id, f),
            Parser::Sep(sep) => todo!(),
            Parser::Delim(delim) => delim.build_parse(id, f),
            Parser::Rec(recursive) => todo!(),
            Parser::Named(named) => named.build_parse(id, f),
            Parser::Fold(fold) => todo!(),
            Parser::Skip(skip) => skip.build_parse(id, f),
            Parser::UnSkip(un_skip) => todo!(),
            Parser::Optional(optional) => todo!(),
            Parser::Recover(recover) => todo!(),
            Parser::NoneOf(none_of) => todo!(),
            Parser::Break(_) => todo!(),
            Parser::FoldOnce(fold_once) => todo!(),
            Parser::Repeated(repeated) => todo!(),
            Parser::Empty => todo!(),
        }
    }
    fn build_peak(&self, id: usize, f: &mut impl Write) {
        match self {
            Parser::Just(just) => just.build_peak(id, f),
            Parser::TokSeq(tok_seq) => todo!(),
            Parser::Choice(choice) => choice.build_peak(id, f),
            Parser::Seq(seq) => seq.build_peak(id, f),
            Parser::Sep(sep) => todo!(),
            Parser::Delim(delim) => delim.build_peak(id, f),
            Parser::Rec(recursive) => todo!(),
            Parser::Named(named) => named.build_peak(id, f),
            Parser::Fold(fold) => todo!(),
            Parser::Skip(skip) => skip.build_peak(id, f),
            Parser::UnSkip(un_skip) => todo!(),
            Parser::Optional(optional) => todo!(),
            Parser::Recover(recover) => todo!(),
            Parser::NoneOf(none_of) => todo!(),
            Parser::Break(_) => todo!(),
            Parser::FoldOnce(fold_once) => todo!(),
            Parser::Repeated(repeated) => todo!(),
            Parser::Empty => todo!(),
        }
    }
    fn build_expected(&self, id: usize, f: &mut impl Write) {}
}

pub trait ParserQBEBuilder {
    fn build_parse(&self, id: usize, f: &mut impl Write);
    fn build_peak(&self, id: usize, f: &mut impl Write);
    fn build_expected(&self, id: usize, f: &mut impl Write);
}

pub fn build_parse_by_id(cache: &ParserCache<RuntimeLang>, f: &mut impl Write) {
    write!(
        f,
        "
function l $peak_by_id(l %state_ptr, l %offset, w %recover, l %id) {{
"
    )
    .unwrap();

    for (index, _) in cache.parsers.iter().enumerate() {
        let next = if index + 1 == cache.parsers.len() {
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
