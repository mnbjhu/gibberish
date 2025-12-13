use std::collections::HashSet;

use gibberish_core::{err::Expected, lang::CompiledLang};

use crate::parser::ptr::{ParserCache, ParserIndex};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct UnSkip {
    pub token: u32,
    pub inner: ParserIndex,
}

impl UnSkip {
    pub fn expected(&self, cache: &ParserCache) -> Vec<Expected<CompiledLang>> {
        self.inner.get_ref(cache).expected(cache)
    }
    pub fn build_parse(&self, id: usize, f: &mut impl std::fmt::Write) {
        write!(
            f,
            "
# Parse Unskip
function l $parse_{id}(l %state_ptr, w %recover, l %unmatched_checkpoint) {{
@start
    %unskipped =l call $unskip(l %state_ptr, l {kind})
    %res =l call $parse_{inner}(l %state_ptr, w %recover, l %unmatched_checkpoint)
    jnz %unskipped, @skip, @ret
@skip
    call $skip(l %state_ptr, l {kind})
    ret %res
@ret
    ret %res
}}",
            inner = self.inner.index,
            kind = self.token
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
    pub fn unskip(self, token: u32, cache: &mut ParserCache) -> ParserIndex {
        Parser::UnSkip(UnSkip { token, inner: self }).cache(cache)
    }
}
