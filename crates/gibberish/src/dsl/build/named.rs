use crate::{
    api::named::Named,
    dsl::{build::ParserQBEBuilder, lexer::RuntimeLang},
};

impl ParserQBEBuilder for Named<RuntimeLang> {
    fn build_parse(&self, id: usize, f: &mut impl std::fmt::Write) {
        write!(
            f,
            "
function w $parse_{id}(l %state_ptr, w %recover) {{
@start
    call $enter_group(l %state_ptr, w {name})
    %res =l call $parse_{inner}(l %state_ptr, w %recover)
    jnz %res, @remove_group, @exit
@exit
    call $exit_group(l %state_ptr)
    ret %res
@remove_group
    %stack_ptr =l add %state_ptr, 24
    call $pop(l %stack_ptr, l 32)
    ret %res
}}",
            name = self.name,
            inner = self.inner.index,
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
