use crate::api::{Parser, choice::choice, just::just, rec::recursive, seq::seq};

use super::{lang::PLang, lexer::PToken, syntax::PSyntax};

pub fn p_parser() -> Parser<PLang> {
    let string = just(PToken::String).named(PSyntax::String);
    recursive(|stmt| {
        let expr = recursive(|ex| {
            let choice_parser = ex
                .clone()
                .sep_by(just(PToken::Or))
                .delim_by(just(PToken::LBracket), just(PToken::RBracket))
                .named(PSyntax::Choice);

            let args = ex
                .sep_by(just(PToken::Comma))
                .delim_by(just(PToken::LParen), just(PToken::RParen));

            let delim_parser = seq(vec![just(PToken::Delim), args.clone()]).named(PSyntax::Delim);

            let sep_parser = seq(vec![just(PToken::SepBy), args.clone()]).named(PSyntax::SepBy);

            let fold_parser = seq(vec![just(PToken::Fold), args.clone()]).named(PSyntax::Fold);

            let named_parser = seq(vec![just(PToken::Named), args.clone()]).named(PSyntax::Named);

            let rec_body = seq(vec![
                just(PToken::Ident).named(PSyntax::Var),
                just(PToken::Colon),
                stmt.clone().sep_by(just(PToken::Semi)),
            ])
            .delim_by(just(PToken::LBrace), just(PToken::RBrace));

            let rec_parser = seq(vec![just(PToken::Rec), rec_body]).named(PSyntax::Rec);

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
                .fold(PSyntax::Seq, seq(vec![just(PToken::Then), atom]))
        });
        seq(vec![
            just(PToken::Ident).named(PSyntax::Var),
            just(PToken::Eq),
            expr,
        ])
        .named(PSyntax::Decl)
    })
    .sep_by(just(PToken::Semi))
    .skip(PToken::Whitespace)
}
