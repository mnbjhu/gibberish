use gibberish_core::err::ParseError;
use gibberish_gibberish_parser::Gibberish;
use tower_lsp::lsp_types::{
    Diagnostic, DiagnosticRelatedInformation, DiagnosticSeverity, DiagnosticTag, Location, Range,
};

use crate::{
    ast::{CheckError, CheckState, RootAst},
    lsp::{Backend, TextDocumentItem, offset_to_position, semantic_token::semantic_token_from_ast},
};

impl Backend {
    pub async fn on_change<'a>(&self, params: TextDocumentItem<'a>) {
        let rope = ropey::Rope::from_str(params.text);
        self.document_map
            .insert(params.uri.to_string(), rope.clone());
        let lst = Gibberish::parse(params.text);
        let mut diagnostics = lst
            .all_leading_errors()
            .filter_map(|(_, err)| {
                let (message, _) = match err {
                    ParseError::MissingError { start, expected } => {
                        let expected_txt = expected
                            .iter()
                            .map(|it| it.debug_name(&Gibberish))
                            .collect::<Vec<_>>()
                            .join(",");
                        let span = *start..=*start;
                        (format!("Missing {expected_txt}"), span)
                    }
                    ParseError::Unexpected { start, actual } => {
                        if let (Some(first), Some(last)) = (actual.first(), actual.last()) {
                            let span = *first.span.start()..=*last.span.end();
                            ("This is unexpected".to_string(), span)
                        } else {
                            ("This is unexpected".to_string(), *start..=*start)
                        }
                    }
                };
                let start_position = offset_to_position(*err.span().start(), &rope)?;
                let end_position = offset_to_position(*err.span().end(), &rope)?;
                Some(Diagnostic::new_simple(
                    Range::new(start_position, end_position),
                    message,
                ))
            })
            .collect::<Vec<_>>();

        let ast = RootAst(lst.as_group());
        let diags = {
            let mut state = CheckState::default();
            ast.check(&mut state);
            state.errors
        };
        let semantic_tokens = semantic_token_from_ast(&ast);

        self.ast_map.insert(params.uri.to_string(), lst);
        for err in diags {
            match err {
                CheckError::Simple {
                    message,
                    span,
                    severity,
                } => {
                    let start_position = offset_to_position(*span.start(), &rope).unwrap();
                    let end_position = offset_to_position(*span.end(), &rope).unwrap();
                    let range = Range::new(start_position, end_position);
                    let mut diag = Diagnostic::new_simple(range, message);
                    diag.severity = Some(severity);
                    diagnostics.push(diag);
                }
                CheckError::Unused(span) => {
                    let start_position = offset_to_position(*span.start(), &rope).unwrap();
                    let end_position = offset_to_position(*span.end(), &rope).unwrap();
                    let range = Range::new(start_position, end_position);
                    let mut diag =
                        Diagnostic::new_simple(range, "This variable is never used".to_string());
                    diag.severity = Some(DiagnosticSeverity::WARNING);
                    diag.tags = Some(vec![DiagnosticTag::UNNECESSARY]);
                    diagnostics.push(diag);
                }
                CheckError::Redeclaration {
                    previous,
                    this,
                    name,
                } => {
                    let start_position = offset_to_position(*this.start(), &rope).unwrap();
                    let end_position = offset_to_position(*this.end(), &rope).unwrap();
                    let this_range = Range::new(start_position, end_position);

                    let start_position = offset_to_position(*previous.start(), &rope).unwrap();
                    let end_position = offset_to_position(*previous.end(), &rope).unwrap();
                    let prev_range = Range::new(start_position, end_position);

                    let mut diag = Diagnostic::new_simple(
                        this_range,
                        format!("Variable '{name}' is already defined"),
                    );

                    diag.severity = Some(DiagnosticSeverity::ERROR);

                    diag.related_information = Some(vec![DiagnosticRelatedInformation {
                        location: Location {
                            uri: params.uri.clone(),
                            range: prev_range,
                        },
                        message: format!("Previous definition of '{name}'"),
                    }]);
                    diagnostics.push(diag);
                }
                CheckError::ParseError(_) => todo!(),
            }
        }

        self.client
            .publish_diagnostics(params.uri.clone(), diagnostics, params.version)
            .await;
        self.semantic_token_map
            .insert(params.uri.to_string(), semantic_tokens);
    }
}
