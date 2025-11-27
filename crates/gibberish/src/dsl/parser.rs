use core::panic;

use gibberish_core::node::Span;

use crate::{
    api::{
        Parser,
        choice::choice,
        just::just,
        named::Named,
        ptr::{ParserCache, ParserIndex},
        seq::seq,
    },
    dsl::ast::{
        RootAst,
        expr::ExprAst,
        stmt::{StmtAst, fold::FoldDefAst, parser::ParserDefAst},
    },
    report::simple::report_simple_error,
};

pub struct ParserBuilder {
    pub lexer: Vec<(String, String)>,
    pub vars: Vec<(String, ParserIndex)>,
    pub cache: ParserCache,
    text: String,
    filename: String,
}

impl ParserBuilder {
    pub fn new(text: String, filename: String) -> Self {
        Self {
            lexer: vec![],
            vars: vec![],
            cache: ParserCache::new(),
            text,
            filename,
        }
    }

    pub fn error(&self, msg: &str, span: Span) {
        report_simple_error(msg, span, &self.text, &self.filename);
    }
}

pub fn build_parser<'a>(ast: RootAst<'a>, builder: &mut ParserBuilder) -> ParserIndex {
    let res = ast
        .iter()
        .filter_map(|it| match it {
            StmtAst::Parser(p) => Some(p.build(builder)),
            StmtAst::Fold(f) => Some(f.build(builder)),
            StmtAst::Highlight(_) => {
                // builder.cache.highlights.push(h.query().build(builder)); // TODO: Re-impement
                None
            }
            StmtAst::Token(t) => {
                let value = t.value().unwrap();
                let mut text = value.text.clone();
                text.remove(0);
                text.pop();
                text = text.replace("\\\\", "\\");
                text = text.replace("\\\"", "\"");
                text = text.replace("\\n", "\n");
                text = text.replace("\\t", "\t");
                text = text.replace("\\f", "\x0C");
                builder.lexer.push((t.name().text.to_string(), text));
                None
            }
            StmtAst::Keyword(k) => {
                let regex = format!("({})[^_a-zA-Z0-9]", k.name().text);
                builder.lexer.push((k.name().text.to_string(), regex));
                None
            }
        })
        .last()
        .unwrap();
    match res.get_ref(&builder.cache) {
        Parser::Named(Named { inner, .. }) => inner.clone(),
        _ => res,
    }
}

impl<'a> ParserDefAst<'a> {
    fn build(&self, builder: &mut ParserBuilder) -> ParserIndex {
        let name = self.name().text.as_str();
        let name_index = builder.vars.len();
        if let Some(expr) = self.expr() {
            let mut p = expr.build(builder);
            if !name.starts_with("_") {
                p = p.named(name_index as u32, &mut builder.cache);
            }
            if builder.replace_var(name, p.clone()) {
                p
            } else {
                builder.vars.push((name.to_string(), p.clone()));
                p
            }
        } else {
            let empty = Parser::Empty.cache(&mut builder.cache);
            builder.vars.push((name.to_string(), empty.clone()));
            empty
        }
    }
}

impl ParserBuilder {
    fn replace_var(&mut self, name: &str, p: ParserIndex) -> bool {
        if let Some(existing) = self.get_var(name) {
            *existing.get_mut(&mut self.cache) = p.get_ref(&self.cache).clone();
            true
        } else {
            false
        }
    }

    pub fn get_var(&self, name: &str) -> Option<ParserIndex> {
        self.vars
            .iter()
            .find_map(|(n, p)| if name == n { Some(p.clone()) } else { None })
    }
}

impl<'a> FoldDefAst<'a> {
    fn build(&self, builder: &mut ParserBuilder) -> ParserIndex {
        let name = self.name().text.as_str();
        assert!(!name.starts_with("_"), "Fold expressions should be named");
        let name_index = builder.vars.len();
        let first = self.first().build(builder);
        let next = self.next().unwrap().build(builder);
        let p = first.fold_once(name_index as u32, next, &mut builder.cache);
        builder.vars.push((name.to_string(), p.clone()));
        p
    }
}

impl<'a> ExprAst<'a> {
    pub fn build(&self, builder: &mut ParserBuilder) -> ParserIndex {
        match self {
            ExprAst::Ident(lexeme) => {
                if let Some(p) = builder
                    .vars
                    .iter()
                    .find(|it| it.0 == lexeme.text)
                    .map(|it| it.1.clone())
                {
                    p
                } else {
                    let tok = builder
                        .lexer
                        .iter()
                        .position(|(name, _)| name == &lexeme.text);
                    if tok.is_none() {
                        builder.error("Name not found", lexeme.span.clone());
                        panic!("Unable to build parser")
                    }
                    just(tok.unwrap() as u32, &mut builder.cache)
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
            ExprAst::Call(member_ast) => {
                let mut expr = member_ast.target().build(builder);
                for member in member_ast.arms() {
                    match member.name().text.as_str() {
                        "repeated" => {
                            let args = member
                                .args()
                                .map(|it| it.build(builder))
                                .collect::<Vec<_>>();
                            if !args.is_empty() {
                                panic!("'repeated' expected no args but {} were found", args.len())
                            }
                            expr = expr.repeated(&mut builder.cache)
                        }
                        "sep_by" => {
                            let args = member
                                .args()
                                .map(|it| it.build(builder))
                                .collect::<Vec<_>>();
                            if args.len() != 1 {
                                panic!("'sep_by' expected one arg but {} were found", args.len())
                            }
                            expr = expr.sep_by(args[0].clone(), &mut builder.cache)
                        }
                        "sep_by_padded" => {
                            let args = member
                                .args()
                                .map(|it| it.build(builder))
                                .collect::<Vec<_>>();
                            if args.len() != 1 {
                                panic!(
                                    "'sep_by_padded' expected one arg but {} were found",
                                    args.len()
                                )
                            }
                            expr = expr.sep_by_extra(args[0].clone(), &mut builder.cache)
                        }
                        "delim_by" => {
                            let args = member
                                .args()
                                .map(|it| it.build(builder))
                                .collect::<Vec<_>>();
                            if args.len() != 2 {
                                panic!("'delim_by' expected 2 args but {} were found", args.len())
                            }
                            expr =
                                expr.delim_by(args[0].clone(), args[1].clone(), &mut builder.cache)
                        }
                        "skip" => {
                            let args = member
                                .args()
                                .map(|it| it.build(builder))
                                .collect::<Vec<_>>();
                            if args.len() != 1 {
                                panic!("'skip' expected 1 arg but {} were found", args.len())
                            }
                            if let Parser::Just(tok) = args[0].get_ref(&builder.cache) {
                                expr = expr.skip(tok.0, &mut builder.cache)
                            } else {
                                panic!("Expected a token but found a parser")
                            }
                        }
                        "unskip" => {
                            let args = member
                                .args()
                                .map(|it| it.build(builder))
                                .collect::<Vec<_>>();
                            if args.len() != 1 {
                                panic!("'unskip' expected 1 arg but {} were found", args.len())
                            }
                            if let Parser::Just(tok) = args[0].get_ref(&builder.cache) {
                                expr = expr.unskip(tok.0, &mut builder.cache)
                            } else {
                                panic!("Expected a token but found a parser")
                            }
                        }
                        "or_not" => {
                            let args = member
                                .args()
                                .map(|it| it.build(builder))
                                .collect::<Vec<_>>();
                            if !args.is_empty() {
                                panic!("'or_not' expected 0 arg but {} were found", args.len())
                            }
                            expr = expr.or_not(&mut builder.cache);
                        }
                        name => builder.error(
                            &format!("Function not found '{name}'"),
                            member.name().span.clone(),
                        ),
                    }
                }
                expr
            }
        }
    }
}
