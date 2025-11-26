use crate::{
    api::just::Just,
    dsl::{build::ParserQBEBuilder, lexer::RuntimeLang},
};

impl ParserQBEBuilder for Just<RuntimeLang> {
    fn build_parse(&self, id: usize, f: &mut impl std::fmt::Write) {
        write!(
            f,
            "

# Parse Just
function w $parse_{id}(l %state_ptr, w %recover) {{
@start
    jmp @check_eof
@check_eof
    %is_eof =w call $is_eof(l %state_ptr)
    jnz %is_eof, @eof, @check_ok
@check_ok
    %current_kind =l call $current_kind(l %state_ptr)
    %res =l ceql %current_kind, {kind}
    jnz %res, @ret_ok, @check_skip
@check_skip
    %skip_ptr =l add %state_ptr, 80
    %is_skipped =l call $contains_long(l %skip_ptr, l %current_kind)
    jnz %is_skipped, @bump_skipped, @recover
@bump_skipped
    call $bump(l %state_ptr)
    jmp @check_eof
@recover
    jnz %recover, @check_delims, @ret_err
@check_delims
    %delim_stack_ptr =l add %state_ptr, 56
    %delim_stack_len =l add %state_ptr, 64
    %index =l loadl %delim_stack_len
    jnz %index, @loop, @ret_err
@loop
    %index =l sub %index, 1
    %parser_index_ptr =l call $get(l %delim_stack_ptr, l 8, l %index)
    %parser_index =l loadl %parser_index_ptr
    %rec_res =l call $peak_by_id(l %state_ptr, l 0, w 0, l %parser_index)
    jnz %rec_res, @iter, @ret_break
@iter
    jnz %index, @loop, @ret_err
@eof
    ret 2
@ret_break
    %break =l add %index, 3
    ret %break
@ret_ok
    call $bump(l %state_ptr)
    ret 0
@ret_err
    ret 1
}}",
            kind = self.0
        )
        .unwrap()
    }

    fn build_peak(&self, id: usize, f: &mut impl std::fmt::Write) {
        write!(
            f,
            "
function w $peak_{id}(l %state_ptr, l %offset, w %recover) {{
@start
    %is_eof =w call $is_eof(l %state_ptr) # TODO: CHANGE TO BE EOF AT OFFSET
    jnz %is_eof, @eof, @check_ok
@eof
    ret 2
@check_ok
    %current_kind =l call $kind_at_offset(l %state_ptr, l %offset)
    %res =l ceql %current_kind, {}
    jnz %res, @ret_ok, @recover
@recover
    jnz %recover, @check_delims, @ret_err
@check_delims
    %delim_stack_ptr =l add %state_ptr, 56
    %delim_stack_len =l add %state_ptr, 64
    %index =l loadl %delim_stack_len
    jnz %index, @loop, @ret_err
@loop
    %index =l sub %index, 1
    %rec_res =l call $peak_by_id(l %state_ptr, l 0, w 0, l %index)
    jnz %rec_res, @iter, @ret_break
@iter
    jnz %index, @loop, @ret_err
@ret_break
    %break =l add %index, 3
    ret %break
@ret_ok
    ret 0
@ret_err
    ret 1
}}",
            self.0
        )
        .unwrap()
    }
}
