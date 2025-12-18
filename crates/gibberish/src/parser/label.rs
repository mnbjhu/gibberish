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
        write!(
            f,
            "
# Parse Label
function l $parse_{id}(l %state_ptr, w %recover, l %unmatched_checkpoint) {{
@start
    %res =l call $parse_{inner}(l %state_ptr, w %recover, l %unmatched_checkpoint)
    ret %res
}}
",
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
