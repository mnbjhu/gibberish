use crate::{
    api::{
        just::just,
        ptr::{ParserCache, ParserIndex},
    },
    dsl::lst::{lang::DslLang, stmt::stmt_parser, token::DslToken},
};

pub mod expr;
pub mod lang;
pub mod stmt;
pub mod syntax;
pub mod token;

pub fn dsl_parser(cache: &mut ParserCache<DslLang>) -> ParserIndex<DslLang> {
    stmt_parser(cache).sep_by(just(DslToken::Semi, cache), cache)
}
