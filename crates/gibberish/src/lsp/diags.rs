use crate::lsp::ServerState;
use async_lsp::{
    LanguageClient as _,
    lsp_types::{Diagnostic, DiagnosticSeverity, PublishDiagnosticsParams, Url},
};
use gibberish_tree::{
    err::{Expected, ParseError},
    lang::{CompiledLang, Lang},
    node::Node,
};

use crate::lsp::span_to_range_str;

pub fn diags(
    node: &Node<CompiledLang>,
    txt: &str,
    lang: &CompiledLang,
    url: &Url,
) -> Vec<Diagnostic> {
    let mut d = vec![];
    match node {
        Node::Group(group) => {
            for child in &group.children {
                d.extend(diags(child, txt, lang, url));
            }
        }
        Node::Lexeme(_) => return vec![],
        Node::Err(parse_error) => match parse_error {
            ParseError::MissingError { expected, start } => {
                let mut related = vec![];
                // diags.push(Diagnostic {
                //     range: span_to_range_str(start_delim.span.clone(), txt),
                //     severity: Some(DiagnosticSeverity::INFORMATION),
                //     code: None,
                //     code_description: None,
                //     source: None,
                //     message: "A delim is opened here".to_string(),
                //     related_information: None,
                //     tags: None,
                //     data: None,
                // });
                // if let Some(before) = before {
                //     diags.push(Diagnostic {
                //         range: span_to_range_str(before.span.clone(), txt),
                //         severity: Some(DiagnosticSeverity::INFORMATION),
                //         code: None,
                //         code_description: None,
                //         source: None,
                //         message: format!(
                //             "Expected {} before here",
                //             expected_text(expected, lang)
                //         ),
                //         related_information: None,
                //         tags: None,
                //         data: None,
                //     });
                // }
                d.push(Diagnostic {
                    range: span_to_range_str(parse_error.span(), txt),
                    severity: Some(DiagnosticSeverity::ERROR),
                    code: None,
                    code_description: None,
                    source: None,
                    message: format!("Missing {:?}", expected_text(expected, lang)),
                    related_information: Some(related),
                    tags: None,
                    data: None,
                })
            }
            ParseError::Unexpected { .. } => d.push(Diagnostic {
                range: span_to_range_str(parse_error.span(), txt),
                severity: Some(DiagnosticSeverity::ERROR),
                code: None,
                code_description: None,
                source: None,
                message: format!("Unexpected"),
                related_information: None,
                tags: None,
                data: None,
            }),
        },
    }
    d
}

fn expected_text<L: Lang>(expected: &Vec<Expected<L>>, lang: &L) -> String {
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

        let ast = self.parser.clone().parse(&text, &self.cache);
        self.client
            .publish_diagnostics(PublishDiagnosticsParams {
                diagnostics: ast.diags(&text, &self.cache.lang, &uri),
                uri,
                version: None,
            })
            .unwrap();
    }
}
