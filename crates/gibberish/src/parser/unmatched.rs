use std::collections::HashSet;

use gibberish_core::{err::Expected, lang::CompiledLang};

use crate::{
    ast::try_parse,
    parser::ptr::{ParserCache, ParserIndex},
};

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Unmatched {
    pub options: Vec<UnmatchedArm>,
}

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub enum UnmatchedArm {
    Finish {
        start: ParserIndex,
        inner: ParserIndex,
        name: u32,
    },
    Unmatched {
        start: ParserIndex,
        next: ParserIndex,
    },
    StartOnly(ParserIndex),
}

impl UnmatchedArm {
    pub fn expected(&self, cache: &ParserCache) -> Vec<Expected<CompiledLang>> {
        self.start().get_ref(cache).expected(cache)
    }

    pub fn start_tokens(&self, cache: &ParserCache) -> HashSet<u32> {
        self.start().get_ref(cache).start_tokens(cache)
    }

    pub fn start(&self) -> ParserIndex {
        match self {
            UnmatchedArm::Finish { start, .. } => start.clone(),
            UnmatchedArm::Unmatched { start, .. } => start.clone(),
            UnmatchedArm::StartOnly(parser_index) => parser_index.clone(),
        }
    }

    pub fn build(&self, cache: &ParserCache, index: usize, f: &mut impl std::fmt::Write) {
        match self {
            UnmatchedArm::Finish { inner, name, .. } => {
                try_parse(
                    inner.index,
                    &format!("finish_{index}"),
                    &format!("@close_group_{index}"),
                    f,
                );
                write!(
                    f,
                    "
@close_group_{index}
    call $group_at(l %state_ptr, w {name}, l %checkpoint)
    ret 0
",
                )
                .unwrap()
            }
            UnmatchedArm::Unmatched { next, .. } => {
                write!(
                    f,
                    "
@try_parse_finish_{index}
    %res =l call $parse_{next}_with_checkpoint(l %state_ptr, w %recover, l %checkpoint)
    %is_err =l ceql 1, %res
    jnz %is_err, @bump_err_finish_{index}, @ret_ok
@bump_err_finish_{index}
    call $bump_err(l %state_ptr)
    jmp @try_parse_finish_{index}
",
                    next = next.index
                )
                .unwrap();
            }
            UnmatchedArm::StartOnly(_) => {
                write!(
                    f,
                    "
@try_parse_finish_{index}
    jmp @ret_ok
",
                )
                .unwrap();
            }
        }
    }
}

impl Unmatched {
    pub fn expected(&self, cache: &ParserCache) -> Vec<Expected<CompiledLang>> {
        self.options
            .iter()
            .flat_map(|it| it.expected(cache))
            .collect()
    }

    pub fn build_parse(&self, cache: &ParserCache, id: usize, f: &mut impl std::fmt::Write) {
        write!(
            f,
            "
function w $parse_{id}(l %state_ptr, w %recover) {{
@start
    %checkpoint =l call $checkpoint(l %state_ptr)
    %res =l call $parse_{id}_with_checkpoint(l %state_ptr, w %recover, l %checkpoint)
    ret %res
}}",
        )
        .unwrap();
        write!(
            f,
            "
function w $parse_{id}_with_checkpoint(l %state_ptr, w %recover, l %checkpoint) {{",
        )
        .unwrap();
        for (index, option) in self.options.iter().enumerate() {
            let next = if index + 1 == self.options.len() {
                "@ret"
            } else {
                &format!("@check_{}", index + 1)
            };
            write!(
                f,
                "
@check_{index}
    %res =l call $parse_{start}(l %state_ptr, w %recover)
    jnz %res, {next}, @try_parse_{index}",
                start = option.start().index
            )
            .unwrap();
        }
        write!(
            f,
            "
@ret
    ret %res
@ret_ok
    ret 0
}}"
        )
        .unwrap();
    }

    pub fn start_tokens(&self, cache: &ParserCache) -> HashSet<u32> {
        let mut set = HashSet::new();
        for option in &self.options {
            set.extend(option.start_tokens(cache));
        }
        set
    }

    pub fn is_optional(&self, cache: &ParserCache) -> bool {
        false // TODO: Look into whether this is easy to support
    }
}
