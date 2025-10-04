use async_lsp::{
    LanguageClient as _,
    lsp_types::{Diagnostic, DiagnosticSeverity, PublishDiagnosticsParams, Url},
};

use crate::{
    cli::lsp::ServerState,
    giblang::{lang::GLang, parser::g_parser},
    lsp::span_to_range_str,
    parser::node::Node,
};

impl Node<GLang> {
    pub fn diags(&self, txt: &str) -> Vec<Diagnostic> {
        let mut diags = vec![];
        let span = self.span();
        match self {
            Node::Group(group) => {
                for child in &group.children {
                    diags.extend(child.diags(txt));
                }
            }
            Node::Lexeme(_) => return vec![],
            Node::Err(parse_error) => diags.push(Diagnostic {
                range: span_to_range_str(span.clone(), txt),
                severity: Some(DiagnosticSeverity::ERROR),
                code: None,
                code_description: None,
                source: None,
                message: format!("Expected {:?}", parse_error.expected),
                related_information: None,
                tags: None,
                data: None,
            }),
        }
        diags
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

        let ast = g_parser().parse(&text);
        self.client
            .publish_diagnostics(PublishDiagnosticsParams {
                uri,
                diagnostics: ast.diags(&text),
                version: None,
            })
            .unwrap();
    }
}
