use std::collections::HashSet;

use gibberish_core::{err::Expected, lang::CompiledLang};

use crate::parser::ptr::{ParserCache, ParserIndex};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Skip {
    pub token: u32,
    pub inner: ParserIndex,
}

impl Skip {
    pub fn expected(&self, cache: &ParserCache) -> Vec<Expected<CompiledLang>> {
        self.inner.get_ref(cache).expected(cache)
    }

    pub fn build_parse(&self, id: usize, f: &mut impl std::fmt::Write) {
        write!(
            f,
            "
# Parse Skip
function w $parse_{id}(l %state_ptr, w %recover) {{
@start
    %after_skipped =l call $after_skipped(l %state_ptr)
    %res =l call $peak_{inner}(l %state_ptr, l %after_skipped, w 1)
    jnz %res, @ret, @parse
@parse
    %skipped =l call $skip(l %state_ptr, l {kind})
    %res =l call $parse_{inner}(l %state_ptr, w %recover)
    jnz %skipped, @unskip, @ret
@unskip
    call $unskip(l %state_ptr, l {kind})
    ret %res
@ret
    ret %res
}}",
            inner = self.inner.index,
            kind = self.token
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
            inner = self.inner.index
        )
        .unwrap()
    }

    pub fn start_tokens(&self, cache: &ParserCache) -> HashSet<u32> {
        self.inner.get_ref(cache).start_tokens(cache)
    }

    pub fn is_optional(&self, cache: &ParserCache) -> bool {
        self.inner.get_ref(cache).is_optional(cache)
    }
}

impl ParserIndex {
    pub fn skip(self, token: u32, cache: &mut ParserCache) -> ParserIndex {
        Parser::Skip(Skip { token, inner: self }).cache(cache)
    }
}
