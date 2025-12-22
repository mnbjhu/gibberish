use std::{collections::HashSet, fmt::Display};

use gibberish_core::{err::Expected, lang::RawLang};

use crate::{ast::builder::ParserBuilder, parser::rename::Rename};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Named {
    pub inner: Box<Parser>,
    pub name: String,
}

impl Named {
    pub fn name_id(&self, builder: &ParserBuilder) -> u32 {
        let group_id = builder
            .vars
            .iter()
            .position(|(name, _)| name == &self.name)
            .unwrap();
        group_id as u32
    }

    pub fn expected(&self, builder: &ParserBuilder) -> Vec<Expected<RawLang>> {
        vec![Expected::Group(self.name_id(builder))]
    }

    pub fn build_parse(
        &self,
        id: usize,
        builder: &mut ParserBuilder,
        f: &mut impl std::fmt::Write,
    ) {
        let inner = self.inner.build(builder, f);
        let name = self.name_id(builder);
        write!(
            f,
            r#"

/* Parse Named */
static size_t parse_{id}(ParserState *state, size_t unmatched_checkpoint) {{
    size_t c = checkpoint(state);
    size_t res = parse_{inner}(state, unmatched_checkpoint);
    if (res == 0) {{
        group_at(state, c, {name});
    }}
    return res;
}}
"#,
            id = id,
            inner = inner,
            name = name
        )
        .unwrap()
    }

    pub fn start_tokens(&self, cache: &ParserBuilder) -> HashSet<String> {
        self.inner.start_tokens(cache)
    }

    pub fn is_optional(&self, cache: &ParserBuilder) -> bool {
        self.inner.is_optional(cache)
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
        self.inner
            .remove_conflicts(builder, depth)
            .named(self.name.clone())
    }
}
impl Display for Named {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}.named({})", self.inner, self.name)
    }
}

impl Parser {
    pub fn named(self, name: String) -> Parser {
        Parser::Named(Named {
            inner: Box::new(self),
            name,
        })
    }
}
