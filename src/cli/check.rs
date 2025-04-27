use std::{
    fs::{self, OpenOptions},
    ops::Range,
    path::Path,
};

use ariadne::{Label, Report, ReportKind, Source};

use crate::{
    dsl::parser::p_parser,
    parser::{lang::Lang, node::Node},
};

pub fn check(path: &Path) {
    let filename = path.to_str().unwrap();

    let log = OpenOptions::new()
        .write(true)
        .create(true)
        .truncate(true)
        .open("out.log")
        .unwrap();

    tracing_subscriber::fmt()
        .with_writer(log)
        .with_ansi(false)
        .init();

    let text = fs::read_to_string(path).unwrap();
    let res = p_parser().parse(&text);
    let mut ok = true;

    res.build_err(filename, &text, &mut (0..0), &mut ok);
    if ok {
        println!("{}", ansi_term::Color::Green.paint("Parse Successful"))
    }
}

impl<L: Lang> Node<L> {
    fn build_err<'src>(
        &self,
        filename: &'src str,
        text: &'src str,
        last: &mut Range<usize>,
        ok: &mut bool,
    ) {
        let a = ariadne::Color::Red;
        match self {
            Node::Group(group) => {
                for child in &group.children {
                    child.build_err(filename, text, last, ok);
                }
            }
            Node::Lexeme(l) => {
                *last = l.span.clone();
            }
            Node::Err(e) => {
                *ok = false;
                let Some(start) = e.actual.first() else {
                    return Report::build(ReportKind::Error, (filename, last.clone()))
                        .with_code(1)
                        .with_message("Parse Error")
                        .with_label(
                            Label::new((filename, last.clone()))
                                .with_message(e.to_string())
                                .with_color(a),
                        )
                        .finish()
                        .print((filename, Source::from(&text)))
                        .unwrap();
                };
                let end = e.actual.last().unwrap();
                let span = start.span.start..end.span.end;
                *last = end.span.clone();
                Report::build(ReportKind::Error, (filename, span.clone()))
                    .with_code(1)
                    .with_message("Parse Error")
                    .with_label(
                        Label::new((filename, span))
                            .with_message(e.to_string())
                            .with_color(a),
                    )
                    .finish()
                    .print((filename, Source::from(&text)))
                    .unwrap();
            }
        }
    }
}
