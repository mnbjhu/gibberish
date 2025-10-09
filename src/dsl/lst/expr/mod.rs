use crate::{
    api::{
        choice::choice,
        just::just,
        ptr::{ParserCache, ParserIndex},
        rec::recursive,
        seq::seq,
    },
    dsl::lst::{lang::DslLang, syntax::DslSyntax, token::DslToken},
};

pub fn expr_parser(cache: &mut ParserCache<DslLang>) -> ParserIndex<DslLang> {
    use DslSyntax as S;
    use DslToken as T;

    let expr = recursive(
        |expr, cache| {
            let name = just(T::Ident, cache).named(S::Name, cache);
            let func_args = expr
                .sep_by(just(T::Comma, cache), cache)
                .delim_by(just(T::LParen, cache), just(T::RParen, cache), cache)
                .named(S::Args, cache);

            let parens = expr.delim_by(just(T::LParen, cache), just(T::RParen, cache), cache);
            let optional = expr.named(S::Optional, cache).delim_by(
                just(T::LBracket, cache),
                just(T::RBracket, cache),
                cache,
            );
            let atom = choice(vec![name, parens, optional], cache);
            let member_call = just(T::Dot, cache)
                .then(
                    just(T::Ident, cache)
                        .named(S::Name, cache)
                        .then(func_args, cache),
                    cache,
                )
                .named(S::CallArm, cache);
            let atom = atom.fold(S::Call, member_call, cache);

            let seq = atom.fold(S::Seq, just(T::Plus, cache).then(atom, cache), cache);
            let choice = seq.fold(S::Choice, just(T::Bar, cache).then(seq, cache), cache);
            choice
        },
        cache,
    );

    expr.fold_once(S::Fold, seq(vec![just(T::Fold, cache), expr], cache), cache)
}
