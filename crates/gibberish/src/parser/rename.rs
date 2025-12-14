use std::collections::HashSet;

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
        write!(
            f,
            "

# Parse Rename
function l $parse_{id}(l %state_ptr, w %recover, l %unmatched_checkpoint) {{
@start
    %res =l call $parse_{inner}(l %state_ptr, w %recover, l %unmatched_checkpoint)
    jnz %res, @ret_err, @rename
@rename
    call $group_at(l %state_ptr, w {name}, l %unmatched_checkpoint)
    ret 0
@ret_err
    ret %res
}}",
            name = builder.get_group_id(&self.name),
        )
        .unwrap()
    }

    pub fn start_tokens(&self, builder: &ParserBuilder) -> HashSet<String> {
        self.inner.start_tokens(builder)
    }

    pub fn is_optional(&self, builder: &ParserBuilder) -> bool {
        self.inner.is_optional(builder)
    }

    pub fn after_token(&self, token: &str, builder: &mut ParserBuilder) -> Option<Parser> {
        self.inner.clone().after_token(token, builder).map(|it| {
            Parser::Rename(Rename {
                inner: Box::new(it),
                name: self.name.to_string(),
            })
        })
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
