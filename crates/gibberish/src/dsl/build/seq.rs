use crate::{
    api::seq::Seq,
    dsl::{
        build::{ParserQBEBuilder, delim_by::try_parse},
        lexer::RuntimeLang,
    },
};

impl ParserQBEBuilder for Seq<RuntimeLang> {
    fn build_parse(&self, id: usize, f: &mut impl std::fmt::Write) {
        let new_delims_len = self.0.len() - 1;
        let magic = new_delims_len + 2;
        let mut iter = self.0.iter();
        let first = iter.next().unwrap();

        write!(
            f,
            "
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
                "@ret_ok"
            } else {
                &format!("@remove_delim_{}", index + 1)
            };

            write!(
                f,
                "
@remove_delim_{index}
    call $pop_delim(l %state_ptr)
    jnz %res, @check_{index}, @try_parse_{index} 
@check_{index}
    %break_index =l sub %magic_num, {index}
    %is_me =l ceql %res, %break_index
    jnz %is_me, @try_parse_{index}, {next}
",
            )
            .unwrap();
            try_parse(part.index, &format!("{index}"), next, f);
        }
        write!(
            f,
            "
@ret_err
    ret %res
@ret_ok
    ret 0
}}"
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
            inner = self.0.first().unwrap().index
        )
        .unwrap()
    }

    fn build_expected(&self, id: usize, f: &mut impl std::fmt::Write) {
        todo!()
    }
}
