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

        // C version of "Parse Named"
        // Signature: parse_{id}(ParserState *state, size_t unmatched_checkpoint)
        // Return codes preserved: 0 ok, 1 err, 2 eof, >=3 break.
        write!(
            f,
            r#"

/* Parse Checkpoint */
static size_t parse_{id}(ParserState *state, size_t unmatched_checkpoint) {{
    size_t c = checkpoint(state);
    size_t res = parse_{inner}(state, c);
    return res;
}}
"#,
            id = id,
            inner = inner,
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
