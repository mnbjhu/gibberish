use std::{collections::HashSet, fmt::Display};

use gibberish_core::{err::Expected, lang::CompiledLang};

use crate::{ast::builder::ParserBuilder, parser::rename::Rename};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Named {
    pub inner: Box<Parser>,
    pub name: String,
}

impl Named {
    pub fn name_id(&self, builder: &ParserBuilder) -> u32 {
        let group_id = builder
            .vars
            .iter()
            .position(|(name, _)| name == &self.name)
            .unwrap();
        group_id as u32
    }

    pub fn expected(&self, builder: &ParserBuilder) -> Vec<Expected<CompiledLang>> {
        vec![Expected::Group(self.name_id(builder))]
    }
    pub fn build_parse(
        &self,
        id: usize,
        builder: &mut ParserBuilder,
        f: &mut impl std::fmt::Write,
    ) {
        let inner = self.inner.build(builder, f);
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
            name = self.name_id(builder),
        )
        .unwrap()
    }

    pub fn start_tokens(&self, cache: &ParserBuilder) -> HashSet<String> {
        self.inner.start_tokens(cache)
    }

    pub fn is_optional(&self, cache: &ParserBuilder) -> bool {
        self.inner.is_optional(cache)
    }

    pub fn after_token(&self, token: &str, builder: &mut ParserBuilder) -> Option<Parser> {
        self.inner.clone().after_token(token, builder).map(|it| {
            Parser::Rename(Rename {
                inner: Box::new(it),
                name: self.name.clone(),
            })
        })
    }
    pub fn remove_conflicts(&self, builder: &mut ParserBuilder, depth: usize) -> Parser {
        self.inner
            .remove_conflicts(builder, depth)
            .named(self.name.clone())
    }
}
impl Display for Named {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}.named({})", self.inner, self.name)
    }
}

impl Parser {
    pub fn named(self, name: String) -> Parser {
        Parser::Named(Named {
            inner: Box::new(self),
            name,
        })
    }
}
