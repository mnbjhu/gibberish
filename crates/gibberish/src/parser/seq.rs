use std::{collections::HashSet, fmt::Display};

use gibberish_core::{err::Expected, lang::RawLang};

use crate::ast::builder::ParserBuilder;

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
    pub fn expected(&self, builder: &ParserBuilder) -> Vec<Expected<RawLang>> {
        self.0.first().unwrap().expected(builder)
    }

    pub fn build_parse(
        &self,
        id: usize,
        builder: &mut ParserBuilder,
        f: &mut impl std::fmt::Write,
    ) {
        let part_ids = self
            .0
            .iter()
            .map(|it| it.build(builder, f))
            .collect::<Vec<_>>();

        let n = part_ids.len();
        assert!(n > 0);
        for (i, pid) in part_ids[1..].iter().enumerate() {
            writeln!(
                f,
                r#"
static bool break_pred_seq_{id}_{i}(ParserState *state) {{
    return peak_{pid}(state, 0, false);
}}
"#,
            )
            .unwrap();
        }

        writeln!(
            f,
            r#"
/* Parse Seq (inline, new break model, emits missing for skipped parts) */
static size_t parse_{id}(ParserState *state, size_t unmatched_checkpoint) {{
"#,
        )
        .unwrap();

        // Push breaks for parts[1..] in reverse order so part 1 is on top.
        if n > 1 {
            for i in (1..n).rev() {
                writeln!(
                    f,
                    "    size_t brk_{i} = push_break(state, break_pred_seq_{id}_{i});"
                )
                .unwrap();
            }
            writeln!(f).unwrap();
        }

        // Part 0: parse with bump_err retry on 1.
        let p0 = part_ids[0];
        writeln!(
            f,
            r#"    size_t res;

    /* Part 0 */
    res = parse_{p0}(state, unmatched_checkpoint);
    if (res != 0) {{
        for(int i = 0; i < {delim_count};i++) {{
            (void)break_stack_pop(&state->breaks, NULL);
        }}
        return res;
    }}

"#,
            delim_count = part_ids.len() - 1
        )
        .unwrap();

        // For parts i>=1:
        // - pop break for i as we advance
        // - if res indicates we should skip i, emit missing(expected_i)
        // - else attempt to parse i, retrying on 1
        for (i, pi) in part_ids[1..].iter().enumerate() {
            writeln!(
                f,
                r#"
    (void)break_stack_pop(&state->breaks, NULL);

    if (res >= 2 && res != brk_{i}) {{
        ExpectedVec e = expected_{pi}();
        missing(state, e);
    }} else {{
        for (;;) {{
            res = parse_{pi}(state, unmatched_checkpoint);
            if (res == 1) {{
                bump_err(state);
                continue;
            }}
            break;
        }}
        if (res >= 2 && res != brk_{i}) {{
            ExpectedVec e = expected_{pi}();
            missing(state, e);
        }}
    }}

"#,
            )
            .unwrap();
        }

        writeln!(
            f,
            r#"
    return 0;
}}
"#,
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
    use gibberish_core::{lang::Lang, node::Node};
    use gibberish_dyn_lib::bindings::{lang::CompiledLang, parse};
    use serial_test::serial;

    use crate::{assert_syntax_kind, assert_token_kind, parser::tests::build_test_parser};

    fn parse_test(text: &str) -> (CompiledLang, Node<CompiledLang>) {
        let parser = r#"keyword first;
keyword second;
token whitespace = "\s+";
parser root = (first + second).skip(whitespace)
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
        lang::Lang,
        node::Node,
    };
    use gibberish_dyn_lib::bindings::{lang::CompiledLang, parse};
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
parser root = _brackets"#;
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
