use crate::{
    api::{Parser, choice::choice, just::just, rec::recursive, seq::seq},
    giblang::{
        lang::GLang,
        lexer::GToken,
        parser::{decl::func::block_parser, ty::type_parser},
        syntax::GSyntax,
    },
};

pub fn expr_parser(stmt: Parser<GLang>) -> Parser<GLang> {
    recursive(|expr| {
        let string = just(GToken::String).named(GSyntax::String);
        let int = just(GToken::Int).named(GSyntax::Int);
        let float = just(GToken::Float).named(GSyntax::Float);
        let var = just(GToken::Ident).named(GSyntax::Var);
        let bool = choice(vec![just(GToken::True), just(GToken::False)]).named(GSyntax::Bool);
        let parens = expr.delim_by(just(GToken::LParen), just(GToken::RParen));
        let lambda_arg = seq(vec![
            just(GToken::Ident).named(GSyntax::Name),
            seq(vec![just(GToken::Colon), type_parser()]).or_not(),
        ]);
        let lambda_args = lambda_arg
            .sep_by(just(GToken::Comma))
            .or_not()
            .delim_by(just(GToken::Bar), just(GToken::Bar));
        let lambda = seq(vec![
            lambda_args.or_not(),
            stmt.clone().sep_by(just(GToken::Semi)).or_not(),
        ])
        .delim_by(just(GToken::LBrace), just(GToken::RBrace));
        let atom = choice(vec![int, bool, float, string, parens, lambda, var]);
        let prodcut = atom.clone().fold(
            GSyntax::Product,
            seq(vec![
                seq(vec![
                    choice(vec![just(GToken::Times), just(GToken::Div)]),
                    just(GToken::Newline).or_not(),
                ]),
                atom,
            ]),
        );
        let sum = prodcut.clone().fold(
            GSyntax::Sum,
            seq(vec![
                seq(vec![
                    choice(vec![just(GToken::Plus), just(GToken::Sub)]),
                    just(GToken::Newline).or_not(),
                ]),
                prodcut,
            ]),
        );
        let eq = sum.clone().fold(
            GSyntax::Equality,
            seq(vec![
                seq(vec![just(GToken::DoubleEq), just(GToken::Newline).or_not()]),
                sum,
            ]),
        );

        let if_ = seq(vec![
            just(GToken::If),
            eq.clone().named(GSyntax::Condition),
            block_parser(stmt.clone()).named(GSyntax::Then),
        ])
        .named(GSyntax::If);
        choice(vec![if_, eq])
    })
}
