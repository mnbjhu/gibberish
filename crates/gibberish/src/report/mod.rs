use ariadne::{Color, Label, Report, ReportKind, Source};
use gibberish_core::{err::ParseError, lang::Lang, node::Node};

pub mod regex;
pub mod simple;

pub fn report_parse_error<L: Lang>(error: &ParseError<L>, src: &str, filename: &str, lang: &L) {
    let red = Color::Red;
    // let blue = Color::Cyan;
    let error_span = error.span();
    match error {
        ParseError::MissingError { expected, .. } => {
            let expected_txt = expected
                .iter()
                .map(|it| it.debug_name(lang))
                .collect::<Vec<_>>()
                .join(",");
            let mut report = Report::build(ReportKind::Error, (filename, error_span.clone()))
                .with_code(3)
                .with_message(format!("Missing {expected_txt}",));
            // Generate & choose some colours for each of our elements
            // let before_span = if let Some(before) = before {
            //     before.span.clone()
            // } else {
            //     src.len()..src.len()
            // };
            report = report.with_label(
                Label::new((filename, error_span))
                    .with_message(format!("Expected {expected_txt} here"))
                    .with_color(red),
            );
            report
                .finish()
                .print((filename, Source::from(src)))
                .unwrap();
        }
        ParseError::Unexpected { .. } => {
            let mut report = Report::build(ReportKind::Error, (filename, error_span.clone()))
                .with_code(3)
                .with_message("Unexpected".to_string());
            // Generate & choose some colours for each of our elements
            report = report.with_label(
                Label::new((filename, error_span.clone()))
                    .with_message("This is unexpected")
                    .with_color(red),
            );
            report
                .finish()
                .print((filename, Source::from(src)))
                .unwrap();
        }
    }
}

pub fn report_errors<L: Lang>(node: &Node<L>, src: &str, filename: &str, lang: &L) -> bool {
    match node {
        Node::Group(group) => group
            .children
            .iter()
            .any(|it| report_errors(it, src, filename, lang)),
        Node::Skipped(_) | Node::Lexeme(_) => false,
        Node::Err(parse_error) => {
            report_parse_error(parse_error, src, filename, lang);
            true
        }
    }
}
