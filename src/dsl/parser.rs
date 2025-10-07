use std::collections::HashMap;

use crate::{
    api::{
        choice::choice,
        just::just,
        ptr::{ParserCache, ParserIndex},
        seq::seq,
    },
    dsl::{
        ast::{AssignableAst, ExprAst, RootAst},
        lexer::{RuntimeLang, RuntimeLexer},
    },
};

pub struct ParserBuilder<'a> {
    pub vars: Vec<(String, ParserIndex<RuntimeLang<'a>>)>,
    pub cache: ParserCache<RuntimeLang<'a>>,
    lexer: &'a RuntimeLexer,
}

impl<'a> ParserBuilder<'a> {
    pub fn new(lang: RuntimeLang<'a>, lexer: &'a RuntimeLexer) -> Self {
        Self {
            vars: vec![],
            cache: ParserCache::new(lang),
            lexer,
        }
    }
}

pub fn build_parser<'a>(
    ast: RootAst<'a>,
    builder: &mut ParserBuilder<'a>,
) -> ParserIndex<RuntimeLang<'a>> {
    ast.iter()
        .filter_map(|it| {
            if let AssignableAst::Expr(e) = it.expr() {
                Some((it.name(), e))
            } else {
                None
            }
        })
        .map(|(name, expr)| {
            let name_index = builder.vars.len();
            let p = expr
                .build(builder)
                .named(name_index as u32, &mut builder.cache);
            builder.vars.push((name.text.clone(), p));
            p
        })
        .last()
        .unwrap()
}

impl<'a> ExprAst<'a> {
    pub fn build(&self, builder: &mut ParserBuilder<'a>) -> ParserIndex<RuntimeLang<'a>> {
        match self {
            ExprAst::Ident(lexeme) => {
                if let Some(p) = builder
                    .vars
                    .iter()
                    .find(|it| it.0 == lexeme.text)
                    .map(|it| it.1)
                {
                    p
                } else {
                    just(
                        builder
                            .lexer
                            .tokens
                            .iter()
                            .position(|(name, _)| name == &lexeme.text)
                            .unwrap() as u32,
                        &mut builder.cache,
                    )
                }
            }
            ExprAst::Seq(seq_ast) => {
                let items = seq_ast
                    .iter()
                    .map(|it| it.build(builder))
                    .collect::<Vec<_>>();
                seq(items, &mut builder.cache)
            }
            ExprAst::Choice(choice_ast) => {
                let items = choice_ast
                    .iter()
                    .map(|it| it.build(builder))
                    .collect::<Vec<_>>();
                choice(items, &mut builder.cache)
            }
            ExprAst::Call(call_ast) => todo!(),
        }
    }
}
