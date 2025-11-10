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
# Parse Delim
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
        try_parse(self.inner.index, "inner", "@check_missing_item", f);
        try_parse(self.end.index, "close", "@check_missing_close", f);
        write!(
            f,
            "
@check_missing_item
    %delim_stack_ptr =l add %state_ptr, 56
    %delim_stack_len_ptr =l add %state_ptr, 64
    %delim_stack_len =l loadl %delim_stack_len_ptr
    %delim_index =l add %delim_stack_len, 2
    %missing_item =l ceql %delim_index, %res
    jnz %missing_item, @missing_item_err, @try_parse_close
@missing_item_err
    %expected =:vec call $expected_{item}()
    call $missing(l %state_ptr, l %expected)
    jmp @try_parse_close
@check_missing_close
    %missing_item =l ceql %delim_index, %res
    jnz %missing_item, @missing_item_err, @ret_ok
@missing_close_err
    %expected =:vec call $expected_{close}()
    call $missing(l %state_ptr, l %expected)
    jmp @ret_ok
@ret_err
    ret %res
@ret_ok
    call $pop_delim(l %state_ptr)
    ret 0
}}",
            item = self.inner.index,
            close = self.end.index,
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
}
