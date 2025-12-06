use std::collections::HashSet;

use gibberish_core::{err::Expected, lang::CompiledLang};

use crate::parser::{
    Parser,
    ptr::{ParserCache, ParserIndex},
};

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Rename {
    pub inner: ParserIndex,
    pub name: u32,
}

impl Rename {
    pub fn expected(&self, cache: &ParserCache) -> Vec<Expected<CompiledLang>> {
        self.inner.get_ref(cache).expected(cache)
    }

    pub fn build_parse(&self, id: usize, f: &mut impl std::fmt::Write) {
        write!(
            f,
            "

# Parse Rename
function w $parse_{id}(l %state_ptr, w %recover) {{
@start
    %res =l call $parse_{inner}(l %state_ptr, w %recover)
    jnz %res, @ret_err, @rename
@rename
    %stack_ptr =l add %state_ptr, 24
    %current_group =l call $last(l %stack_ptr, l 32)
    %kind_ptr =l add %current_group, 4
    storew {name}, %kind_ptr
    ret 0
@ret_err
    ret %res
}}",
            inner = self.inner.index,
            name = self.name,
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
    pub fn rename(self, name: u32, cache: &mut ParserCache) -> ParserIndex {
        Parser::Rename(Rename { inner: self, name }).cache(cache)
    }
}
