use crate::{
    api::{
        choice::choice,
        just::just,
        ptr::{ParserCache, ParserIndex},
        seq::seq,
    },
    dsl::lst::{expr::expr_parser, lang::DslLang, syntax::DslSyntax, token::DslToken},
};

pub fn stmt_parser(cache: &mut ParserCache<DslLang>) -> ParserIndex<DslLang> {
    use DslSyntax as S;
    use DslToken as T;

    let expr = expr_parser(cache);

    let keyword_def = seq(vec![just(T::Keyword, cache), just(T::Ident, cache)], cache)
        .named(S::KeywordDef, cache);

    let token_def = seq(
        vec![
            just(T::Token, cache),
            just(T::Ident, cache),
            just(T::Eq, cache),
            just(T::String, cache),
        ],
        cache,
    )
    .named(S::TokenDef, cache);

    let parser_def = seq(vec![just(T::Parser, cache), just(T::Ident, cache)], cache)
        .then(
            seq(vec![just(T::Eq, cache), expr.named(S::Expr, cache)], cache).or_not(cache),
            cache,
        )
        .named(S::ParserDef, cache);
    choice(vec![token_def, keyword_def, parser_def], cache)
}
