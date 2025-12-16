use std::collections::HashSet;

use crate::ast::{builder::ParserBuilder, try_parse};
use gibberish_core::{err::Expected, lang::CompiledLang};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Delim {
    pub start: Box<Parser>,
    pub end: Box<Parser>,
    pub inner: Box<Parser>,
}

impl Delim {
    pub fn expected(&self, cache: &ParserBuilder) -> Vec<Expected<CompiledLang>> {
        self.start.expected(cache)
    }

    pub fn build_parse(
        &self,
        id: usize,
        builder: &mut ParserBuilder,
        f: &mut impl std::fmt::Write,
    ) {
        let start = self.start.build(builder, f);
        let inner = self.inner.build(builder, f);
        let end = self.end.build(builder, f);
        write!(
            f,
            "
# Parse Delim
function l $parse_{id}(l %state_ptr, w %recover, l %unmatched_checkpoint) {{
@start
    %res =l call $parse_{start}(l %state_ptr, w %recover, l %unmatched_checkpoint)
    jnz %res, @ret_err, @add_delim
@add_delim
    %delim_index =l call $push_delim(l %state_ptr, l {end})
    jmp @try_parse_inner
",
        )
        .unwrap();
        try_parse(inner, "inner", "@check_missing_item", f);
        try_parse(end, "close", "@check_missing_close", f);
        write!(
            f,
            "
@check_missing_item
    jnz %res, @missing_item_err, @try_parse_close
@missing_item_err
    %expected =:vec call $expected_{inner}()
    call $missing(l %state_ptr, l %expected)
    %hit_delim =l ceql %delim_index, %res
    jnz %hit_delim, @try_parse_close, @missing_close_err
@check_missing_close
    jnz %res, @missing_close_err, @ret_ok
@missing_close_err
    %expected =:vec call $expected_{end}()
    call $missing(l %state_ptr, l %expected)
    jmp @ret_ok
@ret_err
    ret %res
@ret_ok
    call $pop_delim(l %state_ptr)
    ret 0
}}",
        )
        .unwrap()
    }

    pub fn start_tokens(&self, builder: &ParserBuilder) -> HashSet<String> {
        self.start.start_tokens(builder)
    }

    pub fn is_optional(&self, _: &ParserBuilder) -> bool {
        false // TODO: Look into whether this is easy to support
    }
}

impl Parser {
    pub fn delim_by(self, start: Parser, end: Parser) -> Parser {
        Parser::Delim(Delim {
            start: Box::new(start),
            end: Box::new(end),
            inner: Box::new(self),
        })
    }
}
