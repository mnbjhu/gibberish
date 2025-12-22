use std::collections::HashSet;
use std::fmt::Display;

use gibberish_core::err::Expected;
use gibberish_core::lang::RawLang;

use crate::ast::builder::ParserBuilder;
use crate::parser::Parser;
use crate::parser::seq::seq;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Repeated(pub Box<Parser>);

impl Display for Repeated {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}.repeated()", self.0)
    }
}

impl Repeated {
    pub fn expected(&self, builder: &ParserBuilder) -> Vec<Expected<RawLang>> {
        self.0.expected(builder)
    }

    pub fn build_parse(
        &self,
        id: usize,
        builder: &mut ParserBuilder,
        f: &mut impl std::fmt::Write,
    ) {
        let inner = self.0.build(builder, f);

        // PeakFunc wrapper for inner (PeakFunc is bool (*)(ParserState*))
        writeln!(
            f,
            r#"
static bool break_pred_rep0_{id}(ParserState *state) {{
    return peak_{inner}(state, 0, false);
}}
"#,
        )
        .unwrap();

        // C version of Parse Rep0
        // - push_break for inner so inner parsers can "break" out cleanly
        // - repeatedly parse inner
        // - if parse returns 1: bump_err and retry (your rule)
        // - if parse returns 0: continue
        // - if parse returns 2 (EOF) or break code: stop successfully
        // - pop break before returning
        write!(
            f,
            r#"
/* Parse Rep0 */
static size_t parse_{id}(ParserState *state, size_t unmatched_checkpoint) {{
    size_t brk = push_break(state, break_pred_rep0_{id});
    size_t res = parse_{inner}(state, unmatched_checkpoint);
    if(res != 0) {{
        (void)break_stack_pop(&state->breaks, NULL);
        return res;
    }}
    for (;;) {{
        size_t res = parse_{inner}(state, unmatched_checkpoint);

        if (res == 0) {{
            continue;
        }}

        if (res == 1) {{
            bump_err(state);
            continue;
        }}

        if (res == brk) {{
            continue;
        }}
        return 0;
    }}

    (void)break_stack_pop(&state->breaks, NULL);
    return 0;
}}
"#,
            id = id,
            inner = inner
        )
        .unwrap();
    }

    pub fn start_tokens(&self, builder: &ParserBuilder) -> HashSet<String> {
        self.0.start_tokens(builder)
    }

    pub fn is_optional(&self, _: &ParserBuilder) -> bool {
        true
    }

    pub fn after_token(
        &self,
        token: &str,
        builder: &ParserBuilder,
    ) -> (Option<Parser>, Option<String>) {
        let (rest, default) = self.0.clone().after_token(token, builder);
        if let Some(after) = rest {
            (
                Some(seq(vec![after, Parser::Repeated(Repeated(self.0.clone()))])),
                default,
            )
        } else {
            (Some(Parser::Repeated(self.clone())), default)
        }
    }
    pub fn remove_conflicts(&self, builder: &ParserBuilder, depth: usize) -> Parser {
        self.0.remove_conflicts(builder, depth).repeated()
    }
}

impl Parser {
    pub fn repeated(self) -> Parser {
        Parser::Repeated(Repeated(Box::new(self)))
    }
}
