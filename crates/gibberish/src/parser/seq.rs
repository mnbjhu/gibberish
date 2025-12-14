use std::collections::HashSet;

use gibberish_core::{err::Expected, lang::CompiledLang};

use crate::{
    ast::{builder::ParserBuilder, try_parse},
    parser::ptr::{ParserCache, ParserIndex},
};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Seq(pub Vec<ParserIndex>);

impl Seq {
    pub fn expected(&self, cache: &ParserCache) -> Vec<Expected<CompiledLang>> {
        self.0
            .first()
            .expect("Seq should have at least one element")
            .get_ref(cache)
            .expected(cache)
    }

    pub fn build_parse(&self, builder: &ParserBuilder, id: usize, f: &mut impl std::fmt::Write) {
        let new_delims_len = self.0.len() - 1;
        let magic = new_delims_len + 3;

        write!(
            f,
            "
# Parse Seq
function l $parse_{id}(l %state_ptr, w %recover, l %unmatched_checkpoint) {{
@add_delims
    %delim_stack_ptr =l add %state_ptr, 56
    %delim_stack_len_ptr =l add %state_ptr, 64
    %delim_stack_len =l loadl %delim_stack_len_ptr
    %magic_num =l add %delim_stack_len, {magic}
",
        )
        .unwrap();
        let mut last_optional_index = 0;

        for part in self.0[1..].iter().rev() {
            writeln!(
                f,
                "\tcall $push_long(l %delim_stack_ptr, l {part_id})",
                part_id = part.index
            )
            .unwrap()
        }

        writeln!(f, "\tjmp @check_start_0").unwrap();

        for (i, parser) in self.0.iter().enumerate() {
            last_optional_index = i;
            if !parser.get_ref(&builder.cache).is_optional(&builder.cache) {
                break;
            }
        }
        let options = &self.0[..last_optional_index + 1];
        for (index, option) in options.iter().enumerate() {
            let fail = if index + 1 == options.len() {
                "@ret_err"
            } else {
                &format!("@check_start_{}", index + 1)
            };
            let pass = if index + 1 == self.0.len() {
                "@check_last"
            } else {
                &format!("@remove_delim_{}", index + 1)
            };

            write!(
                f,
                "
@check_start_{index}
    %res =l call $parse_{option_index}(l %state_ptr, w %recover, l %unmatched_checkpoint)
    jnz %res, {fail}, {pass}",
                option_index = option.index,
            )
            .unwrap();
        }

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
        writeln!(f, "\n\t@ret_err",).unwrap();
        for _ in self.0[1..].iter() {
            writeln!(f, "\tcall $pop(l %delim_stack_ptr, l 8)",).unwrap()
        }
        write!(
            f,
            "
    ret %res
@check_last
    jnz %res, @check_eof_last, @ret_ok
@check_eof_last
    %is_eof =l ceql 2, %res
    jnz %is_eof, @missing_last, @check_break_last
@check_break_last
    %break_index =l sub %magic_num, {last_optional_index}
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
        )
        .unwrap();
    }

    pub fn start_tokens(&self, cache: &ParserCache) -> HashSet<u32> {
        let mut res = HashSet::new();
        for item in &self.0 {
            let item = item.get_ref(cache);
            res.extend(item.start_tokens(cache));
            if !item.is_optional(cache) {
                return res.into_iter().collect();
            }
        }
        res
    }

    pub fn is_optional(&self, cache: &ParserCache) -> bool {
        self.0.iter().all(|it| it.get_ref(cache).is_optional(cache))
    }

    pub fn after_token(&self, token: u32, builder: &mut ParserBuilder) -> Option<ParserIndex> {
        for (index, item) in self.0.iter().enumerate() {
            let item = item.get_ref(&builder.cache).clone();
            if item.start_tokens(&builder.cache).contains(&token) {
                let mut new_seq = self.0[index..].to_vec();
                if new_seq.is_empty() {
                    return None;
                }
                if new_seq.len() == 1 {
                    return new_seq[0]
                        .get_ref(&builder.cache)
                        .clone()
                        .after_token(token, builder);
                }
                let first = new_seq[0]
                    .get_ref(&builder.cache)
                    .clone()
                    .after_token(token, builder);
                if let Some(first) = first {
                    new_seq[0] = first;
                } else {
                    new_seq.remove(0);
                };
                return Some(Parser::Seq(Seq(new_seq)).cache(&mut builder.cache));
            }
            if !item.is_optional(&builder.cache) {
                break;
            }
        }
        None
    }
}

pub fn seq(parts: Vec<ParserIndex>, cache: &mut ParserCache) -> ParserIndex {
    Parser::Seq(Seq(parts)).cache(cache)
}

#[cfg(test)]
mod seq_test {
    use gibberish_core::{
        lang::{CompiledLang, Lang},
        node::Node,
    };
    use gibberish_dyn_lib::bindings::parse;
    use serial_test::serial;

    use crate::{assert_syntax_kind, assert_token_kind, parser::tests::build_test_parser};

    fn parse_test(text: &str) -> (CompiledLang, Node<CompiledLang>) {
        let parser = r#"keyword first;
keyword second;
token whitespace = "\s+";
parser _root = (first + second).skip(whitespace)
        "#;
        let lang = build_test_parser(parser);
        let node = parse(&lang, text);
        (lang, node)
    }

    #[serial]
    #[test]
    fn test_ok() {
        let (lang, node) = parse_test("first second");
        node.debug_print(true, true, &lang);

        assert_syntax_kind!(lang, node, root);
        let children = &node.as_group().children;
        assert_eq!(
            children.len(),
            3,
            "Expected 2 children but got {:#?}",
            node.as_group().children
        );

        assert_token_kind!(lang, &children[0], first);
        assert_token_kind!(lang, &children[1], whitespace);
        assert_token_kind!(lang, &children[2], second);
    }
}

#[cfg(test)]
mod sep_seq_test {
    use gibberish_core::{
        err::{Expected, ParseError},
        lang::{CompiledLang, Lang},
        node::Node,
    };
    use gibberish_dyn_lib::bindings::parse;
    use serial_test::serial;

    use crate::{assert_syntax_kind, assert_token_kind, parser::tests::build_test_parser};

    fn parse_test(text: &str) -> (CompiledLang, Node<CompiledLang>) {
        let parser = r#"token num = "[0-9]+";
token whitespace = "\s+";
token comma = ",";
token l_bracket = "\[";
token r_bracket = "\]";
parser items = num.sep_by(comma);
parser _brackets = l_bracket + items + r_bracket;
parser _root = _brackets"#;
        let lang = build_test_parser(parser);
        let node = parse(&lang, text);
        (lang, node)
    }

    #[serial]
    #[test]
    fn test_ok() {
        let (lang, node) = parse_test("[123,123]");

        assert_syntax_kind!(lang, node, root);
        let children = &node.as_group().children;
        assert_eq!(
            children.len(),
            3,
            "Expected 5 children but got {:?}",
            node.as_group().children
        );

        assert_token_kind!(lang, &children[0], l_bracket);
        assert_syntax_kind!(lang, &children[1], items);
        assert_token_kind!(lang, &children[2], r_bracket);

        let items = &children[1].as_group().children;
        assert_token_kind!(lang, &items[0], num);
        assert_token_kind!(lang, &items[1], comma);
        assert_token_kind!(lang, &items[2], num);
    }

    #[serial]
    #[test]
    fn test_missing_items() {
        let (lang, node) = parse_test("[]");
        assert_syntax_kind!(lang, node, root);
        let children = &node.as_group().children;
        assert_eq!(
            children.len(),
            3,
            "Expected 3 children but got {:?}",
            node.as_group().children
        );
        assert_token_kind!(lang, &children[0], l_bracket);
        assert_token_kind!(lang, &children[2], r_bracket);

        let Node::Err(ParseError::MissingError { expected, .. }) = &children[1] else {
            panic!("Expected a missing error")
        };
        assert_eq!(expected.len(), 1);
        let Expected::Group(t) = &expected[0] else {
            panic!("Expected a missing group");
        };
        assert_eq!(lang.token_name(t), "num");
    }
}
