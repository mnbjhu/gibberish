use crate::{
    cli::lsp::ServerState,
    dsl::lexer::RuntimeLang,
    parser::{
        err::{Expected, ParseError},
        lang::Lang,
    },
};
use async_lsp::{
    LanguageClient as _,
    lsp_types::{
        Diagnostic, DiagnosticRelatedInformation, DiagnosticSeverity, DiagnosticTag, Location,
        PublishDiagnosticsParams, Url,
    },
};

use crate::{lsp::span_to_range_str, parser::node::Node};

impl Node<RuntimeLang> {
    pub fn diags(&self, txt: &str, lang: &RuntimeLang, url: &Url) -> Vec<Diagnostic> {
        let mut diags = vec![];
        match self {
            Node::Group(group) => {
                for child in &group.children {
                    diags.extend(child.diags(txt, lang, url));
                }
            }
            Node::Lexeme(_) => return vec![],
            Node::Err(parse_error) => match parse_error {
                ParseError::MissingError {
                    start_delim,
                    before,
                    expected,
                    ..
                } => {
                    let mut related = vec![];
                    related.push(DiagnosticRelatedInformation {
                        location: Location {
                            uri: url.clone(),
                            range: span_to_range_str(start_delim.span.clone(), txt),
                        },
                        message: format!(
                            "A {} delim is opened here",
                            lang.token_name(&start_delim.kind)
                        ),
                    });
                    if let Some(before) = before {
                        related.push(DiagnosticRelatedInformation {
                            location: Location {
                                uri: url.clone(),
                                range: span_to_range_str(before.span.clone(), txt),
                            },
                            message: format!(
                                "Expected {} before here",
                                expected_text(expected, lang)
                            ),
                        });
                    }
                    diags.push(Diagnostic {
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
                ParseError::Unexpected { expected, .. } => diags.push(Diagnostic {
                    range: span_to_range_str(parse_error.span(), txt),
                    severity: Some(DiagnosticSeverity::ERROR),
                    code: None,
                    code_description: None,
                    source: None,
                    message: format!("Expected {:?}", expected_text(expected, lang)),
                    related_information: None,
                    tags: None,
                    data: None,
                }),
            },
        }
        diags
    }
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
