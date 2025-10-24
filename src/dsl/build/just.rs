use crate::{
    api::just::Just,
    dsl::{build::ParserBuilder, lexer::RuntimeLang},
};

impl ParserBuilder for Just<RuntimeLang> {
    fn build_parse(&self, id: usize, f: &mut impl std::fmt::Write) {
        write!(
            f,
            "
function w $parse_{id}(l %state_ptr) {{
@start
    %is_eof =w call $is_eof(l %state_ptr)
    jnz %is_eof
@eof
    ret 2
@eof
    ret 2
}}"
        )
        .unwrap()
    }

    fn build_peak(&self, id: usize, f: &mut impl std::fmt::Write) {
        todo!()
    }

    fn build_expected(&self, id: usize, f: &mut impl std::fmt::Write) {
        todo!()
    }
}
