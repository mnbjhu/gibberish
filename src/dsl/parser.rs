use crate::api::{Parser, choice::choice, just::just, rec::recursive, seq::seq};

use super::{lang::PLang, lexer::PToken};

pub fn p_parser() -> Parser<PLang> {
    let string = just(PToken::String).named(PToken::String);
    recursive(|stmt| {
        let expr = recursive(|ex| {
            let choice_parser = ex
                .clone()
                .sep_by(just(PToken::Or))
                .delim_by(just(PToken::LBracket), just(PToken::RBracket))
                .named(PToken::Choice);

            let args = ex
                .sep_by(just(PToken::Comma))
                .delim_by(just(PToken::LParen), just(PToken::RParen));

            let delim_parser = seq(vec![just(PToken::DelimKw), args.clone()]).named(PToken::Delim);

            let sep_parser = seq(vec![just(PToken::Sep), args.clone()]).named(PToken::SepBy);

            let fold_parser = seq(vec![just(PToken::FoldKw), args.clone()]).named(PToken::Fold);

            let named_parser = seq(vec![just(PToken::NamedKw), args.clone()]).named(PToken::Named);

            let rec_body = seq(vec![
                just(PToken::Ident).named(PToken::Var),
                just(PToken::Colon),
                stmt.clone().sep_by(just(PToken::Semi)),
            ])
            .delim_by(just(PToken::LBrace), just(PToken::RBrace));

            let rec_parser = seq(vec![just(PToken::RecKw), rec_body]).named(PToken::Rec);

            let atom = choice(vec![
                string.clone(),
                choice_parser,
                sep_parser,
                delim_parser,
                fold_parser,
                named_parser,
                rec_parser,
            ]);

            atom.clone()
                .fold(PToken::Seq, seq(vec![just(PToken::Then), atom]))
        });
        seq(vec![
            just(PToken::Ident).named(PToken::Var),
            just(PToken::Eq),
            expr,
        ])
        .named(PToken::Decl)
    })
    .sep_by(just(PToken::Semi))
}
