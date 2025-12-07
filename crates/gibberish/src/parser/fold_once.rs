use std::collections::HashSet;

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
pub struct FoldOnce {
    pub name: u32,
    pub first: ParserIndex,
    pub next: ParserIndex,
}

impl FoldOnce {
    pub fn expected(&self, cache: &ParserCache) -> Vec<Expected<CompiledLang>> {
        self.first.get_ref(cache).expected(cache)
    }
    pub fn build_parse(&self, id: usize, f: &mut impl std::fmt::Write) {
        write!(
            f,
            "
# Parse Fold
function w $parse_{id}(l %state_ptr, w %recover, l %unmatched_checkpoint) {{
@start
    jmp @check_eof
@check_eof
    %is_eof =w call $is_eof(l %state_ptr)
    jnz %is_eof, @eof, @check_ok
@check_ok
    %res =l call $peak_{first}(l %state_ptr, l 0, w 0)
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
    %res =l call $parse_{first}(l %state_ptr, w %recover, l %unmatched_checkpoint)
    jnz %res, @ret_err, @parse_next
@parse_next
    %res =l call $parse_{next}(l %state_ptr, w %recover)
    jnz %res, @ret_ok, @create_group
@create_group
    call $group_at(l %state_ptr, w {name}, l %checkpoint)
    ret 0
@ret_ok
    ret 0
@ret_err
    ret %res
@eof
    ret 2
}}",
            name = self.name,
            first = self.first.index,
            next = self.next.index,
        )
        .unwrap()
    }

    pub fn build_peak(&self, cache: &ParserCache, id: usize, f: &mut impl std::fmt::Write) {
        write!(
            f,
            "
function l $peak_{id}(l %state_ptr, l %offset, w %recover) {{
@start
    %res =l call $peak_{first}(l %state_ptr, l %offset, w %recover)
    ret %res
}}
",
            first = self.first.index
        )
        .unwrap()
    }

    pub fn start_tokens(&self, cache: &ParserCache) -> HashSet<u32> {
        self.first.get_ref(cache).start_tokens(cache)
    }

    pub fn is_optional(&self, cache: &ParserCache) -> bool {
        self.first.get_ref(cache).is_optional(cache)
    }

    pub fn after_token(&self, token: u32, builder: &mut ParserBuilder) -> Option<ParserIndex> {
        let first = self
            .first
            .get_ref(&builder.cache)
            .clone()
            .after_token(token, builder);
        if let Some(first) = first {
            Some(first.fold_once(self.name, self.next.clone(), &mut builder.cache))
        } else {
            Some(
                Parser::Rename(Rename {
                    inner: self.next.clone(),
                    name: self.name,
                })
                .cache(&mut builder.cache)
                .or_not(&mut builder.cache),
            )
        }
    }
}

impl ParserIndex {
    pub fn fold_once(self, name: u32, next: ParserIndex, cache: &mut ParserCache) -> ParserIndex {
        Parser::FoldOnce(FoldOnce {
            name,
            first: self,
            next,
        })
        .cache(cache)
    }
}
