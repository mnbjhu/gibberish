use std::collections::HashMap;

use gibberish_core::node::Span;

use crate::{lexer::RegexAst, parser::Parser, report::simple::report_simple_error};

pub struct ParserBuilder {
    pub lexer: Vec<(String, RegexAst)>,
    pub vars: Vec<(String, Parser)>,
    pub labels: Vec<String>,
    text: String,
    filename: String,
    has_errored: bool,
    pub built: HashMap<Parser, usize>,
}

impl ParserBuilder {
    pub fn new(text: String, filename: String, labels: Vec<String>) -> Self {
        Self {
            lexer: vec![],
            vars: vec![],
            text,
            filename,
            has_errored: false,
            built: HashMap::new(),
            labels,
        }
    }

    pub fn error(&mut self, msg: &str, span: Span) {
        self.has_errored = true;
        report_simple_error(msg, span, &self.text, &self.filename);
    }

    pub fn get_var(&self, name: &str) -> Option<Parser> {
        self.vars
            .iter()
            .find_map(|(n, p)| if name == n { Some(p.clone()) } else { None })
    }

    pub fn get_token_id(&self, name: &str) -> u32 {
        self.lexer.iter().position(|(it, _)| it == name).unwrap() as u32
    }

    pub fn get_group_id(&self, name: &str) -> u32 {
        self.vars.iter().position(|(it, _)| it == name).unwrap() as u32
    }
}
