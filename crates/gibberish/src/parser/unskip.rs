use std::{collections::HashSet, fmt::Display};

use gibberish_core::{err::Expected, lang::RawLang};

use crate::ast::builder::ParserBuilder;

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct UnSkip {
    pub token: String,
    pub inner: Box<Parser>,
}

impl UnSkip {
    pub fn expected(&self, builder: &ParserBuilder) -> Vec<Expected<RawLang>> {
        self.inner.expected(builder)
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
/* Parse Unskip */
static size_t parse_{id}(ParserState *state, size_t unmatched_checkpoint) {{
    for (;;) {{
        if (state->offset >= state->tokens.len) {{
            return 2; /* EOF */
        }}

        if (peak_{inner}(state, 0, false)) {{
            break;
        }}

        uint32_t k = current_kind(state);
        if (skipped_vec_contains(&state->skipped, k)) {{
            bump_skipped(state);
            continue;
        }}
        break;
    }}
    bool did_unskip = unskip(state, (uint32_t){kind});
    size_t res = parse_{inner}(state, unmatched_checkpoint);
    if (did_unskip) {{
        (void)skip(state, (uint32_t){kind});
    }}
    return res;
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
            .unskip(self.token.clone())
    }
}

impl Display for UnSkip {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}.unskip({})", self.inner, self.token)
    }
}

impl Parser {
    pub fn unskip(self, token: String) -> Parser {
        Parser::UnSkip(UnSkip {
            token,
            inner: Box::new(self),
        })
    }
}
