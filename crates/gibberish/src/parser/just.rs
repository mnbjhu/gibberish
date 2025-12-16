use std::{collections::HashSet, fmt::Display};

use gibberish_core::{err::Expected, lang::CompiledLang};

use crate::ast::builder::ParserBuilder;

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Just(pub String);

impl Just {
    pub fn expected(&self, builder: &ParserBuilder) -> Vec<Expected<CompiledLang>> {
        let token_id = builder
            .lexer
            .iter()
            .position(|(it, _)| it == &self.0)
            .unwrap();
        vec![Expected::Token(token_id as u32)]
    }

    pub fn build_parse(&self, id: usize, builder: &ParserBuilder, f: &mut impl std::fmt::Write) {
        let kind = builder.get_token_id(&self.0);
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
        )
        .unwrap()
    }

    pub fn start_tokens(&self, _: &ParserBuilder) -> HashSet<String> {
        let mut res = HashSet::new();
        res.insert(self.0.clone());
        res
    }

    pub fn is_optional(&self) -> bool {
        false
    }
}

pub fn just(tok: String) -> Parser {
    let p = Parser::Just(Just(tok));
    p
}

impl Display for Just {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.0)
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

    #[serial]
    #[test]
    fn test_keyword_lex() {
        let parser = r#"keyword just;
        parser _root = just"#;
        let lang = build_test_parser(parser);
        let lst = parse(&lang, "just");
        assert_eq!("root", lang.syntax_name(&lst.name()));
        assert_eq!(
            1,
            lst.as_group().children.len(),
            "Expected one child but found {lst:?}"
        );

        let token = lst.as_group().children.first().unwrap();
        if let Node::Lexeme(l) = token {
            assert_eq!("just", lang.token_name(&l.kind))
        } else {
            panic!("Expected a 'just' token but found {token:?}")
        }
    }
}
