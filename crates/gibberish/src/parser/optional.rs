use std::collections::HashSet;

use gibberish_core::{err::Expected, lang::CompiledLang};

use crate::parser::{
    Parser,
    ptr::{ParserCache, ParserIndex},
};

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Optional(pub ParserIndex);

impl Optional {
    pub fn expected(&self, cache: &ParserCache) -> Vec<Expected<CompiledLang>> {
        self.0.get_ref(cache).expected(cache)
    }
    pub fn build_parse(&self, id: usize, f: &mut impl std::fmt::Write) {
        write!(
            f,
            "
# Parse Optional
function w $parse_{id}(l %state_ptr, w %recover) {{
@start
    %res =w call $parse_{inner}(l %state_ptr, w %recover)
    ret %res
}}",
            inner = self.0.index,
        )
        .unwrap()
    }

    pub fn build_peak(&self, cache: &ParserCache, id: usize, f: &mut impl std::fmt::Write) {
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

    pub fn start_tokens(&self, cache: &ParserCache) -> HashSet<u32> {
        self.0.get_ref(cache).start_tokens(cache)
    }

    pub fn is_optional(&self, cache: &ParserCache) -> bool {
        true
    }
}

impl ParserIndex {
    pub fn or_not(self, cache: &mut ParserCache) -> ParserIndex {
        Parser::Optional(Optional(self)).cache(cache)
    }
}
