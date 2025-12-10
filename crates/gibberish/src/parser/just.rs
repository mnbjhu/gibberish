use std::{collections::HashSet, fmt::Display};

use gibberish_core::{err::Expected, lang::CompiledLang};

use crate::{
    ast::builder::ParserBuilder,
    parser::ptr::{ParserCache, ParserIndex},
};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Just(pub u32);

impl Just {
    pub fn expected(&self) -> Vec<Expected<CompiledLang>> {
        vec![Expected::Token(self.0)]
    }

    pub fn build_parse(&self, builder: &ParserBuilder, id: usize, f: &mut impl std::fmt::Write) {
        write!(
            f,
            "

# Parse Just
function l $parse_{id}(l %state_ptr, w %recover, l %unmatched_checkpoint) {{
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

    pub fn build_peak(&self, cache: &ParserCache, id: usize, f: &mut impl std::fmt::Write) {
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

    pub fn start_tokens(&self) -> HashSet<u32> {
        let mut res = HashSet::new();
        res.insert(self.0);
        res
    }

    pub fn is_optional(&self) -> bool {
        false
    }
}

pub fn just(tok: u32, cache: &mut ParserCache) -> ParserIndex {
    let p = Parser::Just(Just(tok));
    p.cache(cache)
}

impl Display for Just {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "Just({})", self.0)
    }
}

#[cfg(test)]
mod tests {
    use gibberish_core::{
        lang::{CompiledLang, Lang},
        node::Node,
    };
    use gibberish_dyn_lib::bindings::parse;
    use serial_test::serial;

    use crate::parser::tests::build_test_parser;

    fn parse_just_test(text: &str) -> (CompiledLang, Node<CompiledLang>) {
        let parser = r#"token num = "[0-9]+";
        token whitespace = "\s+";
        parser _root = num"#;
        let lang = build_test_parser(parser);
        let node = parse(&lang, text);
        (lang, node)
    }

    #[serial]
    #[test]
    fn test_just() {
        let (lang, lst) = parse_just_test("123");
        assert_eq!("root", lang.syntax_name(&lst.name()));
        assert_eq!(1, lst.as_group().children.len());

        let token = lst.as_group().children.first().unwrap();
        if let Node::Lexeme(l) = token {
            assert_eq!("num", lang.token_name(&l.kind))
        } else {
            panic!("Expected a 'just' token but found {token:?}")
        }
    }

    #[serial]
    #[test]
    fn test_just_error() {
        let (lang, lst) = parse_just_test("   123");
        assert_eq!("root", lang.syntax_name(&lst.name()));
        assert_eq!(2, lst.as_group().children.len());

        let error = &lst.as_group().children[0];
        let token = &lst.as_group().children[1];
        if let Node::Err(err) = &error {
            assert_eq!(1, err.actual().len());
            assert_eq!("whitespace", lang.token_name(&err.actual()[0].kind))
        } else {
            panic!("Expected an error node")
        }
        if let Node::Lexeme(l) = token {
            assert_eq!("num", lang.token_name(&l.kind))
        } else {
            panic!("Expected a 'num' token but found {token:?}")
        }
    }

    #[serial]
    #[test]
    fn test_just_missing() {
        let (lang, lst) = parse_just_test("");
        assert_eq!("root", lang.syntax_name(&lst.name()));
        assert_eq!(1, lst.as_group().children.len());
    }

    // #[serial]
    // #[test]
    // fn test_keyword_lex() {
    //     let parser = r#"keyword just;
    //     parser _root = just"#;
    //     let lang = build_test_parser(parser);
    //     let lst = parse(&lang, "just\n");
    //     assert_eq!("root", lang.syntax_name(&lst.name()));
    //     assert_eq!(
    //         1,
    //         lst.as_group().children.len(),
    //         "Expected one child but found {lst:?}"
    //     );
    //
    //     let token = lst.as_group().children.first().unwrap();
    //     if let Node::Lexeme(l) = token {
    //         assert_eq!("just", lang.token_name(&l.kind))
    //     } else {
    //         panic!("Expected a 'just' token but found {token:?}")
    //     }
    // }
}
