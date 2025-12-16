use std::{collections::HashSet, fmt::Display};

use gibberish_core::{err::Expected, lang::CompiledLang};

use crate::ast::builder::ParserBuilder;

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Skip {
    pub token: String,
    pub inner: Box<Parser>,
}

impl Skip {
    pub fn expected(&self, cache: &ParserBuilder) -> Vec<Expected<CompiledLang>> {
        self.inner.expected(cache)
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
# Parse Skip
function l $parse_{id}(l %state_ptr, w %recover, l %unmatched_checkpoint) {{
@start
    %skipped =l call $skip(l %state_ptr, l {kind})
    %res =l call $parse_{inner}(l %state_ptr, w %recover, l %unmatched_checkpoint)
    jnz %skipped, @unskip, @ret
@unskip
    call $unskip(l %state_ptr, l {kind})
    ret %res
@ret
    ret %res
}}",
            kind = builder.get_token_id(&self.token)
        )
        .unwrap()
    }

    pub fn start_tokens(&self, builder: &ParserBuilder) -> HashSet<String> {
        self.inner.start_tokens(builder)
    }

    pub fn is_optional(&self, builder: &ParserBuilder) -> bool {
        self.inner.is_optional(builder)
    }
    pub fn remove_conflicts(&self, builder: &ParserBuilder, depth: usize) -> Parser {
        self.inner
            .remove_conflicts(builder, depth)
            .skip(self.token.clone())
    }
}

impl Display for Skip {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}.skip({})", self.inner, self.token)
    }
}

impl Parser {
    pub fn skip(self, token: String) -> Parser {
        Parser::Skip(Skip {
            token,
            inner: Box::new(self),
        })
    }
}
