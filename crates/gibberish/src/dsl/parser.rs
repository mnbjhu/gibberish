use gibberish_core::node::Span;

use crate::{
    api::{
        Parser,
        named::Named,
        ptr::{ParserCache, ParserIndex},
    },
    dsl::ast::{
        RootAst,
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

impl ParserBuilder {
    pub fn replace_var(&mut self, name: &str, p: ParserIndex) -> bool {
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
