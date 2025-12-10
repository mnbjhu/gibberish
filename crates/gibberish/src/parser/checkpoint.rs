use std::{collections::HashSet, fmt::Display};

use gibberish_core::{err::Expected, lang::CompiledLang};

use crate::parser::ptr::{ParserCache, ParserIndex};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Checkpoint(pub ParserIndex);

impl Checkpoint {
    pub fn expected(&self, cache: &ParserCache) -> Vec<Expected<CompiledLang>> {
        self.0.get_ref(cache).expected(cache)
    }
    pub fn build_parse(&self, id: usize, f: &mut impl std::fmt::Write) {
        write!(
            f,
            "
# Parse Checkpoint
function l $parse_{id}(l %state_ptr, w %recover, l %unmatched_checkpoint) {{
@start
    jmp @check_eof
@check_eof
    %is_eof =w call $is_eof(l %state_ptr)
    jnz %is_eof, @eof, @check_ok
@check_ok
    %res =l call $peak_{inner}(l %state_ptr, l 0, w 0)
    jnz %res, @check_skip, @parse
@check_skip
    %current_kind =l call $current_kind(l %state_ptr)
    %skip_ptr =l add %state_ptr, 80
    %is_skipped =l call $contains_long(l %skip_ptr, l %current_kind)
    jnz %is_skipped, @bump_skipped, @parse
@bump_skipped
    call $bump(l %state_ptr)
    jmp @check_eof
@parse
    %checkpoint =l call $checkpoint(l %state_ptr)
    %res =l call $parse_{inner}(l %state_ptr, w %recover, l %checkpoint)
    ret %res
@eof
    ret 2
}}",
            inner = self.0.index,
        )
        .unwrap()
    }

    pub fn start_tokens(&self, cache: &ParserCache) -> HashSet<u32> {
        self.0.get_ref(cache).start_tokens(cache)
    }

    pub fn is_optional(&self, cache: &ParserCache) -> bool {
        self.0.get_ref(cache).is_optional(cache)
    }

    pub fn after_token(&self, token: u32, cache: &mut ParserCache) -> Option<ParserIndex> {
        panic!("Tried to get after tokens for 'Checkpoint'. Didn't expect this to be needed??")
    }
}
