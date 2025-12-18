use ariadne::{Color, Label, Report, ReportKind, Source};
use tower_lsp::lsp_types::DiagnosticSeverity;

use crate::ast::CheckError;

impl CheckError {
    pub fn report(&self, src: &str, filename: &str) {
        match self {
            CheckError::Simple {
                message,
                span,
                severity,
            } => {
                let color = match *severity {
                    DiagnosticSeverity::ERROR => Color::Red,
                    DiagnosticSeverity::WARNING => Color::Yellow,
                    DiagnosticSeverity::INFORMATION => Color::Blue,
                    DiagnosticSeverity::HINT => Color::Green,
                    _ => panic!("{severity:?} is not a valid severity"),
                };
                let mut report = Report::build(ReportKind::Error, (filename, span.clone()))
                    .with_code("E002")
                    .with_message(message);
                // Generate & choose some colours for each of our elements
                report = report.with_label(
                    Label::new((filename, span.clone()))
                        .with_message(message)
                        .with_color(color),
                );
                report
                    .finish()
                    .print((filename, Source::from(src)))
                    .unwrap();
            }
            CheckError::Unused(span) => {
                let mut report = Report::build(ReportKind::Warning, (filename, span.clone()))
                    .with_code("E003")
                    .with_message("Unused variable");
                // Generate & choose some colours for each of our elements
                report = report.with_label(
                    Label::new((filename, span.clone()))
                        .with_message("Defined here and is never used")
                        .with_color(Color::Red),
                );
                report
                    .finish()
                    .print((filename, Source::from(src)))
                    .unwrap();
            }
            CheckError::Redeclaration {
                previous,
                this,
                name,
            } => {
                let mut report = Report::build(ReportKind::Error, (filename, this.clone()))
                    .with_code("E004")
                    .with_message("Variable has already been defined");

                report = report.with_labels(vec![
                    Label::new((filename, this.clone()))
                        .with_message(format!("The variable '{name}' is already defined"))
                        .with_color(Color::Red),
                    Label::new((filename, previous.clone()))
                        .with_message("Previous definition here")
                        .with_color(Color::Blue),
                ]);
                report
                    .finish()
                    .print((filename, Source::from(src)))
                    .unwrap();
            }
        }
    }
}
