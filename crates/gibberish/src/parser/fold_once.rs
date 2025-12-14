use std::{collections::HashSet, fmt::Display};

use gibberish_core::{err::Expected, lang::CompiledLang};

use crate::{
    ast::{builder::ParserBuilder, try_parse},
    parser::rename::Rename,
};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct FoldOnce {
    pub name: String,
    pub first: Box<Parser>,
    pub next: Box<Parser>,
}

impl Display for FoldOnce {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}.fold({}, {})", self.first, self.name, self.next)
    }
}

impl FoldOnce {
    pub fn expected(&self, builder: &ParserBuilder) -> Vec<Expected<CompiledLang>> {
        self.first.expected(builder)
    }
    pub fn build_parse(
        &self,
        id: usize,
        builder: &mut ParserBuilder,
        f: &mut impl std::fmt::Write,
    ) {
        let first = self.first.build(builder, f);
        let next = self.next.build(builder, f);
        write!(
            f,
            "
# Parse Fold
function l $parse_{id}(l %state_ptr, w %recover, l %unmatched_checkpoint) {{
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
    %break_index =l call $push_delim(l %state_ptr, l {next})
    %res =l call $parse_{first}(l %state_ptr, w %recover, l %unmatched_checkpoint)
    call $pop_delim(l %state_ptr)
    jnz %res, @check_break, @try_parse_next
@check_break
    %is_next =l ceql %res, %break_index
    jnz %is_next, @try_parse_next, @ret_err
",
        )
        .unwrap();
        try_parse(next, "next", "@check_next", f);
        write!(
            f,
            "
@check_next
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
            name = builder.get_group_id(&self.name),
        )
        .unwrap()
    }

    pub fn start_tokens(&self, builder: &ParserBuilder) -> HashSet<String> {
        self.first.start_tokens(builder)
    }

    pub fn is_optional(&self, cache: &ParserBuilder) -> bool {
        self.first.is_optional(cache)
    }

    pub fn after_token(&self, token: &str, builder: &mut ParserBuilder) -> Option<Parser> {
        let first = self.first.clone().after_token(token, builder);
        if let Some(first) = first {
            Some(first.fold_once(self.name.clone(), self.next.as_ref().clone()))
        } else {
            Some(
                Parser::Rename(Rename {
                    inner: self.next.clone(),
                    name: self.name.clone(),
                })
                .or_not(),
            )
        }
    }
    pub fn remove_conflicts(&self, builder: &mut ParserBuilder, depth: usize) -> Parser {
        self.first.remove_conflicts(builder, depth).fold_once(
            self.name.clone(),
            self.next.remove_conflicts(builder, depth),
        )
    }
}

impl Parser {
    pub fn fold_once(self, name: String, next: Parser) -> Parser {
        Parser::FoldOnce(FoldOnce {
            name,
            first: Box::new(self),
            next: Box::new(next),
        })
    }
}
