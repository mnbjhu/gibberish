use ariadne::{Color, Label, Report, ReportKind, Source};

use crate::parser::{
    err::ParseError,
    lang::Lang,
    node::{Node, Span},
};

pub mod regex;
pub mod simple;
impl<L: Lang> ParseError<L> {
    pub fn span(&self) -> Span {
        self.actual()
            .first()
            .map(|it| it.span.start..self.actual().last().unwrap().span.end)
            .unwrap_or(self.start()..self.start())
    }
}

pub fn report_parse_error<L: Lang>(error: &ParseError<L>, src: &str, filename: &str, lang: &L) {
    let red = Color::Red;
    let blue = Color::Cyan;
    let error_span = error.span();
    match error {
        ParseError::MissingError {
            start_delim,
            before,
            expected,
            ..
        } => {
            let expected_txt = expected
                .iter()
                .map(|it| it.debug_name(lang))
                .collect::<Vec<_>>()
                .join(",");
            let mut report = Report::build(ReportKind::Error, (filename, error_span.clone()))
                .with_code(3)
                .with_message(format!("Missing {expected_txt}",));
            // Generate & choose some colours for each of our elements
            let before_span = if let Some(before) = before {
                before.span.clone()
            } else {
                src.len()..src.len()
            };
            report = report.with_label(
                Label::new((filename, error_span))
                    .with_message(format!("Expected {expected_txt} here"))
                    .with_color(red),
            );
            report = report.with_label(
                Label::new((filename, start_delim.span.clone()))
                    .with_message("A delim is opened here".to_string())
                    .with_color(blue),
            );
            report = report.with_label(
                Label::new((filename, before_span))
                    .with_message("and should be closed before for here".to_string())
                    .with_color(blue),
            );
            report
                .finish()
                .print((filename, Source::from(src)))
                .unwrap();
        }
        ParseError::Unexpected { expected, .. } => {
            let expected_txt = expected
                .iter()
                .map(|it| it.debug_name(lang))
                .collect::<Vec<_>>()
                .join(",");
            let mut report = Report::build(ReportKind::Error, (filename, error_span.clone()))
                .with_code(3)
                .with_message(format!("Missing {expected_txt}",));
            // Generate & choose some colours for each of our elements
            report = report.with_label(
                Label::new((filename, error_span.clone()))
                    .with_message(format!(
                        "Expected {expected_txt} but found '{}'",
                        &src[error_span]
                    ))
                    .with_color(red),
            );
            report
                .finish()
                .print((filename, Source::from(src)))
                .unwrap();
        }
    }
}

impl<L: Lang> Node<L> {
    pub fn report_errors(&self, src: &str, filename: &str, lang: &L) -> bool {
        match self {
            Node::Group(group) => group
                .children
                .iter()
                .any(|it| it.report_errors(src, filename, lang)),
            Node::Lexeme(_) => false,
            Node::Err(parse_error) => {
                report_parse_error(parse_error, src, filename, lang);
                true
            }
        }
    }
}
