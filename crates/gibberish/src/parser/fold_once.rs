use std::{collections::HashSet, fmt::Display};

use gibberish_core::{err::Expected, lang::CompiledLang};

use crate::{
    ast::{builder::ParserBuilder, try_parse},
    parser::{rename::Rename, seq::seq},
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
        let group_kind = builder.get_group_id(&self.name);

        // We need a PeakFunc-compatible predicate for the break stack.
        // peak_{next} currently has signature: bool peak_{next}(ParserState*, size_t, bool)
        // PeakFunc is: bool (*)(ParserState*)
        // So we emit a tiny wrapper.
        writeln!(
            f,
            r#"
/* Fold break predicate wrapper */
static bool break_pred_{id}(ParserState *state) {{
    return peak_{next}(state, 0, false);
}}
"#,
        )
        .unwrap();

        writeln!(
            f,
            r#"
/* Parse Fold */
static size_t parse_{id}(ParserState *state, size_t unmatched_checkpoint) {{
    /* Skip leading skipped tokens until either EOF or peak(first) says we can start. */
    for (;;) {{
        if (state->offset >= state->tokens.len) {{
            return 2; /* EOF */
        }}

        if (peak_{first}(state, 0, false)) {{
            break;
        }}

        uint32_t k = current_kind(state);
        if (skipped_vec_contains(&state->skipped, k)) {{
            bump_skipped(state);
            continue;
        }}

        /* Not start token and not skippable: fall through to parse attempt */
        break;
    }}

    size_t c = checkpoint(state);

    /* Push break predicate for "next" and get the break code that child parsers will return */
    size_t break_code = push_break(state, break_pred_{id});

    /* Parse first */
    size_t res = parse_{first}(state, unmatched_checkpoint);

    /* Pop the break predicate we pushed */
    (void)break_stack_pop(&state->breaks, NULL);

    /* If parse_{first} failed for a reason other than our break, propagate it */
    if (res != 0 && res != break_code) {{
        return res;
    }}

    /* Try parse next */
    for(;;){{
        size_t res_next = parse_{next}(state, unmatched_checkpoint);
        if (res_next == 1) {{
            bump_err(state);
            continue;
        }}
        if (res_next != 0) {{
            return 0;
        }}
        (void)group_at(state, c, {group_kind});
        return 0;
    }}
}}
"#,
            id = id,
            first = first,
            next = next,
            group_kind = group_kind,
        )
        .unwrap();
    }

    pub fn start_tokens(&self, builder: &ParserBuilder) -> HashSet<String> {
        self.first.start_tokens(builder)
    }

    pub fn is_optional(&self, cache: &ParserBuilder) -> bool {
        self.first.is_optional(cache)
    }

    pub fn after_token(
        &self,
        token: &str,
        builder: &ParserBuilder,
    ) -> (Option<Parser>, Option<String>) {
        let (first, default) = self.first.clone().after_token(token, builder);
        if let Some(first) = first {
            (
                Some(seq(vec![
                    first,
                    self.next.clone().rename(self.name.clone()).or_not(),
                ])),
                default,
            )
        } else {
            (
                Some(
                    Parser::Rename(Rename {
                        inner: self.next.clone(),
                        name: self.name.clone(),
                    })
                    .or_not(),
                ),
                default,
            )
        }
    }
    pub fn remove_conflicts(&self, builder: &ParserBuilder, depth: usize) -> Parser {
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
