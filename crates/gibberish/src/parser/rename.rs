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
function w $parse_{id}(l %state_ptr, w %recover, l %unmatched_checkpoint) {{
@start
    %res =l call $parse_{inner}(l %state_ptr, w %recover, l %unmatched_checkpoint)
    jnz %res, @ret_err, @rename
@rename
    call $group_at(l %state_ptr, w {name}, l %unmatched_checkpoint)
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

    pub fn after_token(&self, token: u32, cache: &mut ParserCache) -> Option<ParserIndex> {
        self.inner
            .get_ref(cache)
            .clone()
            .after_token(token, cache)
            .map(|it| {
                Parser::Rename(Rename {
                    inner: it,
                    name: self.name,
                })
                .cache(cache)
            })
    }
}

impl ParserIndex {
    pub fn rename(self, name: u32, cache: &mut ParserCache) -> ParserIndex {
        Parser::Rename(Rename { inner: self, name }).cache(cache)
    }
}
