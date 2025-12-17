use std::{collections::HashSet, fmt::Display};

use gibberish_core::{err::Expected, lang::CompiledLang};

use crate::{ast::builder::ParserBuilder, parser::Parser};

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Checkpoint(pub Box<Parser>);

impl Checkpoint {
    pub fn expected(&self, builder: &ParserBuilder) -> Vec<Expected<CompiledLang>> {
        self.0.expected(builder)
    }
    pub fn build_parse(
        &self,
        id: usize,
        builder: &mut ParserBuilder,
        f: &mut impl std::fmt::Write,
    ) {
        let inner = self.0.build(builder, f);
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
    call $bump_skipped(l %state_ptr)
    jmp @check_eof
@parse
    %checkpoint =l call $checkpoint(l %state_ptr)
    %res =l call $parse_{inner}(l %state_ptr, w %recover, l %checkpoint)
    ret %res
@eof
    ret 2
}}",
        )
        .unwrap()
    }

    pub fn start_tokens(&self, builder: &ParserBuilder) -> HashSet<String> {
        self.0.start_tokens(builder)
    }

    pub fn is_optional(&self, builder: &ParserBuilder) -> bool {
        self.0.is_optional(builder)
    }
}

impl Display for Checkpoint {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}.checkpoint()", self.0)
    }
}
