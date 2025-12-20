use std::{collections::HashSet, fmt::Display};

use gibberish_core::{err::Expected, lang::CompiledLang};

use crate::{ast::builder::ParserBuilder, parser::Parser};

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Rename {
    pub inner: Box<Parser>,
    pub name: String,
}

impl Rename {
    pub fn expected(&self, builder: &ParserBuilder) -> Vec<Expected<CompiledLang>> {
        self.inner.expected(builder)
    }

    pub fn build_parse(
        &self,
        id: usize,
        builder: &mut ParserBuilder,
        f: &mut impl std::fmt::Write,
    ) {
        let inner = self.inner.build(builder, f);
        let name = builder.get_group_id(&self.name);

        // C version of "Parse Rename"
        // Signature: parse_{id}(ParserState *state, size_t unmatched_checkpoint)
        // If inner succeeds, wrap/move nodes after checkpoint into a new group (rename) and succeed.
        // If inner fails, propagate its error code.
        write!(
            f,
            r#"

/* Parse Rename */
static size_t parse_{id}(ParserState *state, size_t unmatched_checkpoint) {{
    size_t res = parse_{inner}(state, unmatched_checkpoint);
    if (res != 0) {{
        return res;
    }}

    /* group_at makes a new group from elements after checkpoint; then we tag it with `name`. */
    (void)group_at(state, unmatched_checkpoint, {name});


    return 0;
}}
"#,
            id = id,
            inner = inner,
            name = name
        )
        .unwrap()
    }
    pub fn start_tokens(&self, builder: &ParserBuilder) -> HashSet<String> {
        self.inner.start_tokens(builder)
    }

    pub fn is_optional(&self, builder: &ParserBuilder) -> bool {
        self.inner.is_optional(builder)
    }

    pub fn after_token(
        &self,
        token: &str,
        builder: &ParserBuilder,
    ) -> (Option<Parser>, Option<String>) {
        let (rest, default) = self.inner.clone().after_token(token, builder);
        if let Some(rest) = rest {
            let rest = Parser::Rename(Rename {
                inner: Box::new(rest),
                name: self.name.clone(),
            });
            (Some(rest), default)
        } else {
            (None, Some(self.name.clone()))
        }
    }

    pub fn remove_conflicts(&self, builder: &ParserBuilder, depth: usize) -> Parser {
        Parser::Rename(Rename {
            inner: Box::new(self.inner.remove_conflicts(builder, depth)),
            name: self.name.to_string(),
        })
    }
}
impl Display for Rename {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}.rename({})", self.inner, self.name)
    }
}

impl Parser {
    pub fn rename(self, name: String) -> Parser {
        Parser::Rename(Rename {
            inner: Box::new(self),
            name,
        })
    }
}
