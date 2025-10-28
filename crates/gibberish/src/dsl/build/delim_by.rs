use crate::{
    api::delim::Delim,
    dsl::{build::ParserQBEBuilder, lexer::RuntimeLang},
};

pub fn try_parse(id: usize, name: &str, after: &str, f: &mut impl std::fmt::Write) {
    write!(
        f,
        "
@try_parse_{name}
    %res =l call $parse_{id}(l %state_ptr, w %recover)
    %is_err =l ceql 1, %res
    jnz %is_err, @bump_err_{name}, {after}
@bump_err_{name}
    call $bump_err(l %state_ptr)
    jmp @try_parse_{name}
",
    )
    .unwrap();
}

impl ParserQBEBuilder for Delim<RuntimeLang> {
    fn build_parse(&self, id: usize, f: &mut impl std::fmt::Write) {
        write!(
            f,
            "
function w $parse_{id}(l %state_ptr, w %recover) {{
@start
    %res =l call $parse_{open}(l %state_ptr, w %recover)
    jnz %res, @ret_err, @add_delim
@add_delim
    call $push_delim(l %state_ptr, l {close})
    jmp @try_parse_inner
",
            open = self.start.index,
            close = self.end.index,
        )
        .unwrap();
        try_parse(self.inner.index, "inner", "@try_parse_close", f);
        try_parse(self.end.index, "close", "@ret_ok", f);
        write!(
            f,
            "
@ret_err
    ret %res
@ret_ok
    call $pop_delim(l %state_ptr)
    ret 0
}}",
            // inner = self.inner.index,
            // close = self.close.index,
        )
        .unwrap()
    }

    fn build_peak(&self, id: usize, f: &mut impl std::fmt::Write) {
        write!(
            f,
            "
function w $peak_{id}(l %state_ptr, l %offset, w %recover) {{
@start
    %res =l call $peak_{open}(l %state_ptr, l %offset, w %recover)
    ret %res
}}",
            open = self.start.index
        )
        .unwrap()
    }

    fn build_expected(&self, id: usize, f: &mut impl std::fmt::Write) {
        todo!()
    }
}
