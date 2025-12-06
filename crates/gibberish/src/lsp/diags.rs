use crate::lsp::ServerState;
use async_lsp::{
    LanguageClient as _,
    lsp_types::{Diagnostic, DiagnosticSeverity, PublishDiagnosticsParams, Url},
};
use gibberish_core::{
    err::{Expected, ParseError},
    lang::{CompiledLang, Lang},
    node::Node,
};
use gibberish_dyn_lib::bindings::parse;

use crate::lsp::span_to_range_str;

pub fn diags(node: &Node<CompiledLang>, txt: &str, lang: &CompiledLang) -> Vec<Diagnostic> {
    let mut d = vec![];
    match node {
        Node::Group(group) => {
            for child in &group.children {
                d.extend(diags(child, txt, lang));
            }
        }
        Node::Lexeme(_) => return vec![],
        Node::Err(parse_error) => match parse_error {
            ParseError::MissingError { expected, .. } => d.push(Diagnostic {
                range: span_to_range_str(parse_error.span(), txt),
                severity: Some(DiagnosticSeverity::ERROR),
                code: None,
                code_description: None,
                source: None,
                message: format!("Missing {:?}", expected_text(expected, lang)),
                related_information: Some(vec![]),
                tags: None,
                data: None,
            }),
            ParseError::Unexpected { .. } => d.push(Diagnostic {
                range: span_to_range_str(parse_error.span(), txt),
                severity: Some(DiagnosticSeverity::ERROR),
                code: None,
                code_description: None,
                source: None,
                message: "Unexpected".to_string(),
                related_information: None,
                tags: None,
                data: None,
            }),
        },
    }
    d
}

fn expected_text<L: Lang>(expected: &[Expected<L>], lang: &L) -> String {
    match expected.len() {
        0 => "Nothing".to_string(),
        1 => expected[0].debug_name(lang),
        _ => format!(
            "one of {}",
            expected
                .iter()
                .map(|it| it.debug_name(lang))
                .collect::<Vec<_>>()
                .join(",")
        ),
    }
}

impl ServerState {
    pub fn publish_diags(&mut self, uri: Url) {
        let path = uri.to_file_path().unwrap();

        let text: String = self
            .db
            .get(path.to_str().unwrap())
            .map(|v| v.clone())
            .unwrap_or_default();

        let ast = parse(&self.parser.lock().unwrap(), &text);
        self.client
            .publish_diagnostics(PublishDiagnosticsParams {
                diagnostics: diags(&ast, &text, &self.parser.lock().unwrap()),
                uri,
                version: None,
            })
            .unwrap();
    }
}
