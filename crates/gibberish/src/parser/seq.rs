use std::{collections::HashSet, fmt::Display};

use gibberish_core::{err::Expected, lang::CompiledLang};

use crate::ast::{builder::ParserBuilder, try_parse};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Seq(pub Vec<Parser>);

impl Display for Seq {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "(")?;
        for (index, item) in self.0.iter().enumerate() {
            if index == 0 {
                write!(f, "{item}")?
            } else {
                write!(f, " + {item}")?
            }
        }
        write!(f, ")")
    }
}

impl Seq {
    pub fn expected(&self, builder: &ParserBuilder) -> Vec<Expected<CompiledLang>> {
        self.0.first().unwrap().expected(builder)
    }

    pub fn build_parse(
        &self,
        id: usize,
        builder: &mut ParserBuilder,
        f: &mut impl std::fmt::Write,
    ) {
        let parts = self
            .0
            .iter()
            .map(|it| it.build(builder, f))
            .collect::<Vec<_>>();
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

        for part in parts[1..].iter().rev() {
            writeln!(f, "\tcall $push_long(l %delim_stack_ptr, l {part})",).unwrap()
        }

        writeln!(f, "\tjmp @check_start_0").unwrap();

        for (i, parser) in self.0.iter().enumerate() {
            last_optional_index = i;
            if !parser.is_optional(&builder) {
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
                option_index = option.get_id(builder),
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
                last = self.0[index - 1].get_id(builder)
            )
            .unwrap();
            try_parse(part.get_id(builder), &format!("{index}"), next, f);
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
            last = self.0.last().unwrap().get_id(builder),
        )
        .unwrap();
    }

    pub fn start_tokens(&self, cache: &ParserBuilder) -> HashSet<String> {
        let mut res = HashSet::new();
        for item in &self.0 {
            res.extend(item.start_tokens(cache));
            if !item.is_optional(cache) {
                return res.into_iter().collect();
            }
        }
        res
    }

    pub fn is_optional(&self, builder: &ParserBuilder) -> bool {
        self.0.iter().all(|it| it.is_optional(builder))
    }

    pub fn after_token(
        &self,
        token: &str,
        builder: &ParserBuilder,
    ) -> (Option<Parser>, Option<String>) {
        let index = self
            .0
            .iter()
            .position(|it| it.start_tokens(builder).contains(token))
            .unwrap();
        let mut new_seq = self.0[index..].to_vec();
        if new_seq.len() == 1 {
            return new_seq[0].clone().after_token(token, builder);
        }
        let (first, default) = new_seq[0].clone().after_token(token, builder);
        if let Some(first) = first {
            new_seq[0] = first;
        } else {
            new_seq.remove(0);
        };
        (Some(Parser::Seq(Seq(new_seq))), default)
    }
    pub fn remove_conflicts(&self, builder: &ParserBuilder, depth: usize) -> Parser {
        seq(self
            .0
            .iter()
            .map(|it| it.remove_conflicts(builder, depth))
            .collect())
    }
}

pub fn seq(parts: Vec<Parser>) -> Parser {
    Parser::Seq(Seq(parts))
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
