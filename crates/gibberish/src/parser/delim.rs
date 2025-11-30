use std::collections::HashSet;

use crate::{
    ast::try_parse,
    parser::ptr::{ParserCache, ParserIndex},
};
use gibberish_core::{err::Expected, lang::CompiledLang};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Delim {
    pub start: ParserIndex,
    pub end: ParserIndex,
    pub inner: ParserIndex,
}

impl Delim {
    pub fn expected(&self, cache: &ParserCache) -> Vec<Expected<CompiledLang>> {
        self.start.get_ref(cache).expected(cache)
    }

    pub fn build_parse(&self, id: usize, f: &mut impl std::fmt::Write) {
        write!(
            f,
            "
# Parse Delim
function w $parse_{id}(l %state_ptr, w %recover) {{
@start
    %res =l call $parse_{open}(l %state_ptr, w %recover)
    jnz %res, @ret_err, @add_delim
@add_delim
    %delim_index =l call $push_delim(l %state_ptr, l {close})
    jmp @try_parse_inner
",
            open = self.start.index,
            close = self.end.index,
        )
        .unwrap();
        try_parse(self.inner.index, "inner", "@check_missing_item", f);
        try_parse(self.end.index, "close", "@check_missing_close", f);
        write!(
            f,
            "
@check_missing_item
    jnz %res, @missing_item_err, @try_parse_close
@missing_item_err
    %expected =:vec call $expected_{item}()
    call $missing(l %state_ptr, l %expected)
    %hit_delim =l ceql %delim_index, %res
    jnz %hit_delim, @try_parse_close, @missing_close_err
@check_missing_close
    jnz %res, @missing_close_err, @ret_ok
@missing_close_err
    %expected =:vec call $expected_{close}()
    call $missing(l %state_ptr, l %expected)
    jmp @ret_ok
@ret_err
    ret %res
@ret_ok
    call $pop_delim(l %state_ptr)
    ret 0
}}",
            item = self.inner.index,
            close = self.end.index,
        )
        .unwrap()
    }

    pub fn build_peak(&self, id: usize, f: &mut impl std::fmt::Write) {
        write!(
            f,
            "
function w $peak_{id}(l %state_ptr, l %offset, w %recover) {{
@start
    %res =l call $peak_{open}(l %state_ptr, l %offset, w %recover)
    ret %res
}}",
            open = self.start.index
        )
        .unwrap()
    }

    pub fn start_tokens(&self, cache: &ParserCache) -> HashSet<u32> {
        self.start.get_ref(cache).start_tokens(cache)
    }

    pub fn is_optional(&self, cache: &ParserCache) -> bool {
        false // TODO: Look into whether this is easy to support
    }
}

impl ParserIndex {
    pub fn delim_by(
        self,
        start: ParserIndex,
        end: ParserIndex,
        cache: &mut ParserCache,
    ) -> ParserIndex {
        Parser::Delim(Delim {
            start,
            end,
            inner: self,
        })
        .cache(cache)
    }
}
