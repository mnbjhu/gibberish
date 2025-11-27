use gibberish_core::err::Expected;
use gibberish_core::lang::CompiledLang;

use crate::api::Parser;

use crate::api::ptr::{ParserCache, ParserIndex};
use crate::dsl::ast::try_parse;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Repeated(pub ParserIndex);

impl Repeated {
    pub fn expected(&self, cache: &ParserCache) -> Vec<Expected<CompiledLang>> {
        self.0.get_ref(cache).expected(cache)
    }
    pub fn build_parse(&self, id: usize, f: &mut impl std::fmt::Write) {
        write!(
            f,
            "
# Parse Rep0
function w $parse_{id}(l %state_ptr, w %recover) {{
@start
    call $push_delim(l %state_ptr, l {inner})
    %res =l call $parse_{inner}(l %state_ptr, w %recover)
    jnz %res, @ret_err, @check_eof
@check_eof
    %is_eof =w call $is_eof(l %state_ptr)
    jnz %is_eof, @ret_ok, @try_parse_inner
",
            inner = self.0.index
        )
        .unwrap();
        try_parse(self.0.index, "inner", "@iter", f);
        write!(
            f,
            "
@iter
    jnz %res, @ret_ok, @try_parse_inner
@ret_ok
    call $pop_delim(l %state_ptr)
    ret 0
@ret_err
    call $pop_delim(l %state_ptr)
    ret %res
}}",
        )
        .unwrap()
    }

    pub fn build_peak(&self, id: usize, f: &mut impl std::fmt::Write) {
        write!(
            f,
            "
function l $peak_{id}(l %state_ptr, l %offset, w %recover) {{
@start
    %res =l call $peak_{inner}(l %state_ptr, l %offset, w %recover)
    ret %res
}}
",
            inner = self.0.index
        )
        .unwrap()
    }
}

impl ParserIndex {
    pub fn repeated(self, cache: &mut ParserCache) -> ParserIndex {
        Parser::Repeated(Repeated(self)).cache(cache)
    }
}
