use gibberish_core::{err::Expected, lang::CompiledLang};

use crate::api::ptr::{ParserCache, ParserIndex};

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
# Parse Named
function w $parse_{id}(l %state_ptr, w %recover) {{
@start
    call $enter_group(l %state_ptr, w {name})
    %res =l call $parse_{first}(l %state_ptr, w %recover)
    jnz %res, @remove_group, @parse_next
@parse_next
    %res =l call $parse_{next}(l %state_ptr, w %recover)
    jnz %res, @disolve_group, @exit
@disolve_group
    %stack_ptr =l add %state_ptr, 24
    %current_group =l call $last(l %stack_ptr, l 32)
    call $pop(l %stack_ptr, l 32)
    %outer_group =l call $last(l %stack_ptr, l 32)

    %current_ptr_ptr =l add %current_group, 8
    %current_len_ptr =l add %current_group, 16
    %current_len =l loadl %current_len_ptr
    %current_ptr =l loadl %current_ptr_ptr
    %current_size =l mul %current_len, 32

    %outer_ptr_ptr =l add %outer_group, 8
    %outer_len_ptr =l add %outer_group, 16
    %outer_cap_ptr =l add %outer_group, 24
    %outer_len =l loadl %outer_len_ptr
    %outer_len_ptr =l add %outer_group, 16
    %outer_len =l loadl %outer_len_ptr
    %outer_ptr =l loadl %outer_ptr_ptr
    %outer_size =l mul %outer_len, 32

    %new_len =l add %current_len, %outer_len
    %new_cap =l mul %new_len, 2
    %new_size =l mul %new_len, 64
    %new_ptr =l call $malloc(l %new_size)
    %added_ptr =l add %new_ptr, %outer_size

    call $memcpy(l %new_ptr, l %outer_ptr, l %outer_size)
    call $memcpy(l %added_ptr, l %current_ptr, l %current_size)

    call $free(l %outer_ptr)
    call $free(l %current_ptr)

    storel %new_ptr, %outer_ptr_ptr
    storel %new_len, %outer_len_ptr
    storel %new_cap, %outer_cap_ptr

    ret 0
@exit
    call $exit_group(l %state_ptr)
    ret %res
@remove_group
    %stack_ptr =l add %state_ptr, 24
    call $pop(l %stack_ptr, l 32)
    ret %res
}}",
            name = self.name,
            first = self.first.index,
            next = self.next.index,
        )
        .unwrap()
    }

    pub fn build_peak(&self, id: usize, f: &mut impl std::fmt::Write) {
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
