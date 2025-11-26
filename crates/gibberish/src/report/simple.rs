use ariadne::{Color, Label, Report, ReportKind, Source};
use gibberish_core::node::Span;

pub fn report_simple_error(msg: &str, span: Span, src: &str, filename: &str) {
    let red = Color::Red;
    let mut report = Report::build(ReportKind::Error, (filename, span.clone()))
        .with_code(3)
        .with_message(msg);
    // Generate & choose some colours for each of our elements
    report = report.with_label(
        Label::new((filename, span))
            .with_message(msg)
            .with_color(red),
    );
    report
        .finish()
        .print((filename, Source::from(src)))
        .unwrap();
}
