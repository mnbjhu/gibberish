use crate::{
    api::seq::Seq,
    dsl::build::{ParserQBEBuilder, delim_by::try_parse},
};

impl ParserQBEBuilder for Seq {
    fn build_parse(&self, id: usize, f: &mut impl std::fmt::Write) {
        let new_delims_len = self.0.len() - 1;
        let magic = new_delims_len + 3;
        let mut iter = self.0.iter();
        let first = iter.next().unwrap();

        write!(
            f,
            "
# Parse Seq
function w $parse_{id}(l %state_ptr, w %recover) {{
@add_delims
    %delim_stack_ptr =l add %state_ptr, 56
    %delim_stack_len_ptr =l add %state_ptr, 64
    %delim_stack_len =l loadl %delim_stack_len_ptr
    %magic_num =l add %delim_stack_len, {magic}
",
        )
        .unwrap();

        for part in self.0[1..].iter().rev() {
            writeln!(
                f,
                "\tcall $push_long(l %delim_stack_ptr, l {part_id})",
                part_id = part.index
            )
            .unwrap()
        }

        write!(
            f,
            "
@parse_first
    %res =l call $parse_{first_part}(l %state_ptr, w %recover)
    jnz %res, @ret_err, @remove_delim_1
",
            first_part = first.index,
        )
        .unwrap();

        for (index, part) in self.0.iter().enumerate() {
            if index == 0 {
                continue;
            }
            let next = if index + 1 == self.0.len() {
                "@check_last"
            } else {
                &format!("@remove_delim_{}", index + 1)
            };

            write!(
                f,
                "
@remove_delim_{index}
    call $pop_delim(l %state_ptr)
    jnz %res, @check_eof_{index}, @try_parse_{index} 
@check_eof_{index}
    %is_eof =l ceql 2, %res
    jnz %is_eof, @missing_{index}, @check_{index}
@check_{index}
    %break_index =l sub %magic_num, {index}
    %is_me =l ceql %res, %break_index
    %expected =:vec call $expected_{last}()
    call $missing(l %state_ptr, l %expected)
    jnz %is_me, @try_parse_{index}, {next}
@missing_{index}
    %expected =:vec call $expected_{last}()
    call $missing(l %state_ptr, l %expected)
    jmp @try_parse_{index}
",
                last = self.0[index - 1].index
            )
            .unwrap();
            try_parse(part.index, &format!("{index}"), next, f);
        }
        write!(
            f,
            "
@ret_err
    ret %res
@check_last
    jnz %res, @check_eof_last, @ret_ok
@check_eof_last
    %is_eof =l ceql 2, %res
    jnz %is_eof, @missing_last, @check_break_last
@check_break_last
    %break_index =l sub %magic_num, {index}
    %is_me =l ceql %res, %break_index
    jnz %is_me, @ret_ok, @missing_last
@missing_last
    %expected =:vec call $expected_{last}()
    call $missing(l %state_ptr, l %expected)
    jmp @ret_ok
@ret_ok
    ret 0
}}",
            last = self.0.last().unwrap().index,
            index = self.0.len() - 1,
        )
        .unwrap();
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
            inner = self.0.first().unwrap().index,
        )
        .unwrap()
    }
}
