use crate::{
    api::sep::Sep,
    dsl::build::{ParserQBEBuilder, delim_by::try_parse},
};

impl ParserQBEBuilder for Sep {
    fn build_parse(&self, id: usize, f: &mut impl std::fmt::Write) {
        write!(
            f,
            "
# Parse Sep
function w $parse_{id}(l %state_ptr, w %recover) {{
@start
    %item_index =l call $push_delim(l %state_ptr, l {item})
    %sep_index =l call $push_delim(l %state_ptr, l {sep})
    %res =l call $parse_{item}(l %state_ptr, w %recover)
    jnz %res, @ret_err, @try_parse_sep
@check_sep
    jnz %res, @check_sep_eof, @try_parse_item
@check_sep_eof
    %is_eof =w ceql %res, 2
    jnz %is_eof, @ret_ok, @sep_check_item_delim
@sep_check_item_delim
    %is_item =w ceql %item_index, %res
    jnz %is_item, @missing_sep, @ret_ok
@missing_sep
    %expected =:vec call $expected_{sep}()
    call $missing(l %state_ptr, l %expected)
    jmp @try_parse_item
@check_item
    jnz %res, @check_item_eof, @try_parse_sep
@check_item_eof
    %expected =:vec call $expected_{item}()
    call $missing(l %state_ptr, l %expected)
    %is_eof =w ceql %res, 2
    jnz %is_eof, @ret_ok, @item_check_sep_delim
@item_check_sep_delim
    %is_sep =w ceql %sep_index, %res
    jnz %is_sep, @try_parse_sep, @ret_ok
",
            sep = self.sep.index,
            item = self.item.index,
        )
        .unwrap();
        try_parse(self.sep.index, "sep", "@check_sep", f);
        try_parse(self.item.index, "item", "@check_item", f);
        write!(
            f,
            "
@ret_ok
    call $pop_delim(l %state_ptr)
    ret 0
@ret_err
    call $pop_delim(l %state_ptr)
    ret %res
}}",
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
            inner = self.item.index
        )
        .unwrap()
    }
}
