use std::collections::HashSet;

use gibberish_core::{err::Expected, lang::CompiledLang};

use crate::{ast::builder::ParserBuilder, parser::Parser};

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Optional(pub Box<Parser>);

impl Optional {
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
        write!(
            f,
            "
# Parse Optional
function l $parse_{id}(l %state_ptr, w %recover, l %unmatched_checkpoint) {{
@start
    %res =l call $parse_{inner}(l %state_ptr, w %recover, l %unmatched_checkpoint)
    ret %res
}}",
        )
        .unwrap()
    }

    pub fn start_tokens(&self, cache: &ParserBuilder) -> HashSet<String> {
        self.0.start_tokens(cache)
    }

    pub fn is_optional(&self, _: &ParserBuilder) -> bool {
        true
    }

    pub fn after_token(&self, token: &str, builder: &mut ParserBuilder) -> Option<Parser> {
        self.0.clone().after_token(token, builder)
    }
}

impl Parser {
    pub fn or_not(self) -> Parser {
        Parser::Optional(Optional(Box::new(self)))
    }
}
