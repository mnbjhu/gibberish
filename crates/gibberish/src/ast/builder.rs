use gibberish_core::node::Span;

use crate::{
    lexer::RegexAst,
    parser::ptr::{ParserCache, ParserIndex},
    report::simple::report_simple_error,
};

pub struct ParserBuilder {
    pub lexer: Vec<(String, RegexAst)>,
    pub vars: Vec<(String, ParserIndex)>,
    pub cache: ParserCache,
    text: String,
    filename: String,
    has_errored: bool,
}

impl ParserBuilder {
    pub fn new(text: String, filename: String) -> Self {
        Self {
            lexer: vec![],
            vars: vec![],
            cache: ParserCache::new(),
            text,
            filename,
            has_errored: false,
        }
    }

    pub fn error(&mut self, msg: &str, span: Span) {
        self.has_errored = true;
        report_simple_error(msg, span, &self.text, &self.filename);
    }

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
