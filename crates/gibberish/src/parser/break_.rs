use std::{collections::HashSet, fmt::Display};

use gibberish_core::{err::Expected, lang::RawLang};

use crate::ast::builder::ParserBuilder;

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Break {
    pub inner: Box<Parser>,
    pub at: Box<Parser>,
}

impl Break {
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
        let at = self.at.build(builder, f);
        writeln!(
            f,
            r#"
static bool break_pred_{id}(ParserState *state) {{
    return peak_{at}(state, 0, false);
}}
"#,
        )
        .unwrap();

        writeln!(
            f,
            r#"
/* Parse Fold */
static size_t parse_{id}(ParserState *state, size_t unmatched_checkpoint) {{
    size_t break_code = push_break(state, break_pred_{id});
    size_t res = parse_{inner}(state, unmatched_checkpoint);
    (void)break_stack_pop(&state->breaks, NULL);
    if (res == break_code) {{
        return 1;
    }}
    return res;
}}
"#,
        )
        .unwrap();
    }

    pub fn is_optional(&self, builder: &ParserBuilder) -> bool {
        self.inner.is_optional(builder)
    }
}

impl Display for Break {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}.break({})", self.inner, self.at)
    }
}

impl Parser {
    pub fn break_at(self, at: Parser) -> Parser {
        Parser::Break(Break {
            inner: Box::new(self),
            at: Box::new(at),
        })
    }
}
