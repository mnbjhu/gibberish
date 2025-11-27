use crate::{api::optional::Optional, dsl::build::ParserQBEBuilder};

impl ParserQBEBuilder for Optional {
    fn build_parse(&self, id: usize, f: &mut impl std::fmt::Write) {
        write!(
            f,
            "
# Parse Optional
function w $parse_{id}(l %state_ptr, w %recover) {{
@start
    call $parse_{inner}(l %state_ptr, w %recover)
    ret 0
}}",
            inner = self.0.index,
        )
        .unwrap()
    }

    fn build_peak(&self, id: usize, f: &mut impl std::fmt::Write) {
        write!(
            f,
            "
function l $peak_{id}(l %state_ptr, l %offset, w %recover) {{
@start
    %res =l call $peak_{inner}(l %state_ptr, l %offset, w %recover)
    ret %res
}}
",
            inner = self.0.index
        )
        .unwrap()
    }
}
