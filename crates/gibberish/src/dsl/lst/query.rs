use crate::{
    api::{
        just::just,
        ptr::{ParserCache, ParserIndex},
        rec::recursive,
    },
    dsl::lst::{lang::DslLang, syntax::DslSyntax, token::DslToken},
};

pub fn query_parser(cache: &mut ParserCache<DslLang>) -> ParserIndex<DslLang> {
    use DslSyntax as S;
    use DslToken as T;

    recursive(
        |query, cache| {
            let group = query
                .sep_by(just(T::Comma, cache), cache)
                .delim_by(just(T::LParen, cache), just(T::RParen, cache), cache)
                .named(S::Group, cache);
            let query = just(T::Ident, cache)
                .named(S::Name, cache)
                .then(
                    just(T::Colon, cache).then(group, cache).or_not(cache),
                    cache,
                )
                .named(S::Query, cache);
            query.fold_once(
                S::LabelQuery,
                just(T::At, cache).then(just(T::String, cache).named(S::Label, cache), cache),
                cache,
            )
        },
        cache,
    )
}
