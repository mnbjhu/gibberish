use std::{collections::HashSet, fmt::Display};

use gibberish_core::{err::Expected, lang::RawLang};

use crate::ast::builder::ParserBuilder;

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Skip {
    pub token: String,
    pub inner: Box<Parser>,
}

impl Skip {
    pub fn expected(&self, cache: &ParserBuilder) -> Vec<Expected<RawLang>> {
        self.inner.expected(cache)
    }

    pub fn build_parse(
        &self,
        id: usize,
        builder: &mut ParserBuilder,
        f: &mut impl std::fmt::Write,
    ) {
        let inner = self.inner.build(builder, f);
        let kind = builder.get_token_id(&self.token);

        // C version of "Parse Skip"
        // Signature: parse_{id}(ParserState *state, size_t unmatched_checkpoint)
        // Temporarily marks `kind` as skippable, parses inner, then restores previous state.
        write!(
            f,
            r#"

/* Parse Skip */
static size_t parse_{id}(ParserState *state, size_t unmatched_checkpoint) {{
    bool did_skip = skip(state, (uint32_t){kind});
    size_t res = parse_{inner}(state, unmatched_checkpoint);
    if (did_skip) {{
        (void)unskip(state, (uint32_t){kind});
    }}
    return res;
}}
"#,
            id = id,
            inner = inner,
            kind = kind
        )
        .unwrap();
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
