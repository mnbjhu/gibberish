use std::fmt::Display;

use gibberish_core::{err::Expected, lang::CompiledLang};

use crate::api::ptr::{ParserCache, ParserIndex};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Named {
    pub inner: ParserIndex,
    pub name: u32,
}

impl Named {
    pub fn expected(&self) -> Vec<Expected<CompiledLang>> {
        vec![Expected::Label(self.name)]
    }
    pub fn build_parse(&self, id: usize, f: &mut impl std::fmt::Write) {
        write!(
            f,
            "
# Parse Named
function w $parse_{id}(l %state_ptr, w %recover) {{
@start
    call $enter_group(l %state_ptr, w {name})
    %res =l call $parse_{inner}(l %state_ptr, w %recover)
    jnz %res, @remove_group, @exit
@exit
    call $exit_group(l %state_ptr)
    ret %res
@remove_group
    %stack_ptr =l add %state_ptr, 24
    call $pop(l %stack_ptr, l 32)
    ret %res
}}",
            name = self.name,
            inner = self.inner.index,
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
