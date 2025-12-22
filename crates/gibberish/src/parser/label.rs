use crate::{ast::builder::ParserBuilder, parser::Parser};

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Label {
    pub name: String,
    pub inner: Box<Parser>,
}

impl Label {
    pub fn build_parse(
        &self,
        id: usize,
        builder: &mut ParserBuilder,
        f: &mut impl std::fmt::Write,
    ) {
        let inner = self.inner.build(builder, f);

        // C version of "Parse Label"
        // Signature: parse_{id}(ParserState *state, size_t unmatched_checkpoint)
        // Just forwards to the inner parser.
        write!(
            f,
            r#"

/* Parse Label */
static size_t parse_{id}(ParserState *state, size_t unmatched_checkpoint) {{
    return parse_{inner}(state, unmatched_checkpoint);
}}
"#,
            id = id,
            inner = inner
        )
        .unwrap();
    }
}

impl Parser {
    pub fn labelled(self, name: String) -> Parser {
        Parser::Label(Label {
            name,
            inner: Box::new(self),
        })
    }
}
