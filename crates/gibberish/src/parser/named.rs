use std::{collections::HashSet, fmt::Display};

use gibberish_core::{err::Expected, lang::CompiledLang};

use crate::{
    ast::builder::ParserBuilder,
    parser::{
        ptr::{ParserCache, ParserIndex},
        rename::Rename,
    },
};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Named {
    pub inner: ParserIndex,
    pub name: u32,
}

impl Named {
    pub fn expected(&self) -> Vec<Expected<CompiledLang>> {
        vec![Expected::Group(self.name)]
    }
    pub fn build_parse(&self, id: usize, f: &mut impl std::fmt::Write) {
        write!(
            f,
            "
# Parse Named
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
    call $enter_group(l %state_ptr, w {name})
    %res =l call $parse_{inner}(l %state_ptr, w %recover, l %unmatched_checkpoint)
    jnz %res, @remove_group, @exit
@exit
    call $exit_group(l %state_ptr)
    ret %res
@remove_group
    %stack_ptr =l add %state_ptr, 24
    call $pop(l %stack_ptr, l 32)
    ret %res
@eof
    ret 2
}}",
            name = self.name,
            inner = self.inner.index,
        )
        .unwrap()
    }

    pub fn start_tokens(&self, cache: &ParserCache) -> HashSet<u32> {
        self.inner.get_ref(cache).start_tokens(cache)
    }

    pub fn is_optional(&self, cache: &ParserCache) -> bool {
        self.inner.get_ref(cache).is_optional(cache)
    }

    pub fn after_token(&self, token: u32, builder: &mut ParserBuilder) -> Option<ParserIndex> {
        self.inner
            .get_ref(&builder.cache)
            .clone()
            .after_token(token, builder)
            .map(|it| {
                Parser::Rename(Rename {
                    inner: it,
                    name: self.name,
                })
                .cache(&mut builder.cache)
            })
    }
}

impl ParserIndex {
    pub fn named(self, name: u32, cache: &mut ParserCache) -> ParserIndex {
        Parser::Named(Named { inner: self, name }).cache(cache)
    }
}

impl Display for Named {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "Named({})", self.name)
    }
}
