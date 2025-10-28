use crate::{
    api::skip::Skip,
    dsl::{build::ParserQBEBuilder, lexer::RuntimeLang},
};

impl ParserQBEBuilder for Skip<RuntimeLang> {
    fn build_parse(&self, id: usize, f: &mut impl std::fmt::Write) {
        write!(
            f,
            "
function w $parse_{id}(l %state_ptr, w %recover) {{
@start
    %after_skipped =l call $after_skipped(l %state_ptr)
    %res =l call $peak_{inner}(l %state_ptr, l %after_skipped, w 1)
    jnz %res, @ret, @parse
@parse
    %skipped =l call $skip(l %state_ptr, l {kind})
    %res =l call $parse_{inner}(l %state_ptr, w %recover)
    jnz %skipped, @unskip, @ret
@unskip
    call $unskip(l %state_ptr, l {kind})
    ret %res
@ret
    ret %res
}}",
            inner = self.inner.index,
            kind = self.token
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
            inner = self.inner.index
        )
        .unwrap()
    }

    fn build_expected(&self, id: usize, f: &mut impl std::fmt::Write) {
        todo!()
    }
}
