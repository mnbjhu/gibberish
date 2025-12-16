use std::collections::HashSet;
use std::fmt::Display;

use gibberish_core::err::Expected;
use gibberish_core::lang::CompiledLang;

use crate::ast::builder::ParserBuilder;
use crate::parser::Parser;
use crate::parser::seq::seq;

use crate::ast::try_parse;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Repeated(pub Box<Parser>);

impl Display for Repeated {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}.repeated()", self.0)
    }
}

impl Repeated {
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
# Parse Rep0
function l $parse_{id}(l %state_ptr, w %recover, l %unmatched_checkpoint) {{
@start
    call $push_delim(l %state_ptr, l {inner})
    %res =l call $parse_{inner}(l %state_ptr, w %recover, l %unmatched_checkpoint)
    jnz %res, @ret_err, @check_eof
@check_eof
    %is_eof =w call $is_eof(l %state_ptr)
    jnz %is_eof, @ret_ok, @try_parse_inner
",
        )
        .unwrap();
        try_parse(inner, "inner", "@iter", f);
        write!(
            f,
            "
@iter
    jnz %res, @ret_ok, @try_parse_inner
@ret_ok
    call $pop_delim(l %state_ptr)
    ret 0
@ret_err
    call $pop_delim(l %state_ptr)
    ret %res
}}",
        )
        .unwrap()
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
