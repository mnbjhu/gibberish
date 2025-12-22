use std::{
    collections::{HashMap, HashSet},
    fmt::Display,
};

use gibberish_core::{err::Expected, lang::RawLang};

use crate::{
    ast::builder::ParserBuilder,
    parser::{checkpoint::Checkpoint, just::just, seq::seq},
};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Choice {
    pub options: Vec<Parser>,
    pub default: Option<String>,
    pub after_default: Vec<Parser>,
}

impl Display for Choice {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "(")?;
        for (index, item) in self.options.iter().enumerate() {
            if index == 0 {
                write!(f, "{item}")?
            } else {
                write!(f, " | {item}")?
            }
        }
        if let Some(d) = &self.default {
            write!(f, " :{d}")?
        }
        for (index, item) in self.after_default.iter().enumerate() {
            if index == 0 {
                write!(f, ": {item}")?
            } else {
                write!(f, " | {item}")?
            }
        }
        write!(f, ")")
    }
}

impl Choice {
    pub fn expected(&self, builder: &ParserBuilder) -> Vec<Expected<RawLang>> {
        self.options
            .iter()
            .flat_map(|it| it.expected(builder))
            .collect()
    }

    pub fn build_parse(
        &self,
        id: usize,
        builder: &mut ParserBuilder,
        f: &mut impl std::fmt::Write,
    ) {
        let options = self
            .options
            .iter()
            .map(|it| it.build(builder, f))
            .collect::<Vec<_>>();

        let after_default = self
            .after_default
            .iter()
            .map(|it| it.build(builder, f))
            .collect::<Vec<_>>();

        let (has_default, default_group_id) = match &self.default {
            Some(d) if d == "%default_unmatched%" => (true, Some(builder.vars.len() as u32)),
            Some(name) => (true, Some(builder.get_group_id(name))),
            None => (false, None),
        };
        writeln!(
            f,
            r#"
/* Build Choice */
static size_t parse_{id}(ParserState *state, size_t unmatched_checkpoint) {{
"#,
        )
        .unwrap();

        if options.is_empty() {
            writeln!(f, "    size_t res = 1;").unwrap();
        } else {
            writeln!(f, "    size_t res = 1;").unwrap();
            for opt in &options {
                writeln!(
                    f,
                    r#"
    res = parse_{opt}(state, unmatched_checkpoint);
    if (res == 0) {{
        return 0;
    }}
"#,
                )
                .unwrap();
            }
        }

        if has_default {
            let gid = default_group_id.unwrap();
            writeln!(
                f,
                r#"
    /* default branch */
    group_at(state, unmatched_checkpoint, (uint32_t){gid});
"#,
            )
            .unwrap();

            if after_default.is_empty() {
                writeln!(f, "    return res;").unwrap();
            } else {
                for aft in &after_default {
                    writeln!(
                        f,
                        r#"
    res = parse_{aft}(state, unmatched_checkpoint);
    if (res != 0) {{
        return res;
    }}
"#,
                    )
                    .unwrap();
                }
                writeln!(f, "    return 0;").unwrap();
            }
        } else {
            writeln!(f, "    return res;").unwrap();
        }

        writeln!(f, "}}\n").unwrap();
    }

    pub fn start_tokens(&self, builder: &ParserBuilder) -> HashSet<String> {
        let mut set = HashSet::new();
        for option in &self.options {
            set.extend(option.start_tokens(builder));
        }
        for option in &self.after_default {
            set.extend(option.start_tokens(builder));
        }
        set
    }

    pub fn is_optional(&self, _: &ParserBuilder) -> bool {
        if let Some(d) = &self.default
            && d != "%default_unmatched%"
        {
            true
        } else {
            false
        }
    }

    pub fn after_token(
        &self,
        token: &str,
        builder: &ParserBuilder,
    ) -> (Option<Parser>, Option<String>) {
        let mut parsers = vec![];
        for (index, p) in self.options.iter().enumerate() {
            if p.start_tokens(builder).contains(token) {
                parsers.push(index);
            }
        }
        if parsers.is_empty() {
            panic!()
        }
        let mut default = None;
        let mut options = vec![];
        let mut after_default = vec![];
        for index in parsers {
            match self.options[index].clone().after_token(token, builder) {
                (None, None) => {}
                (None, Some(d)) => {
                    if let Some(existing) = default.clone() {
                        assert_eq!(
                            d, existing,
                            "Only one default is supported, (this should be a caught error)"
                        )
                    } else {
                        default = Some(d.clone())
                    }
                }
                (Some(option), None) => {
                    options.push(option);
                }
                (Some(option), Some(d)) => {
                    after_default.push(option);
                    if let Some(default) = default.clone() {
                        assert_eq!(
                            d, default,
                            "Only one default is supported, (this should be a caught error)"
                        )
                    } else {
                        default = Some(d)
                    }
                }
            }
        }
        // TODO: lots of thinking here
        if options.is_empty() {
            if after_default.is_empty() {
                return (None, default);
            } else {
                return (
                    Some(Parser::Choice(Choice {
                        after_default,
                        default,
                        options: vec![],
                    })),
                    None,
                );
            }
        }
        if options.len() == 1 && default.is_none() {
            return (Some(options[0].clone()), None);
        }
        (
            Some(Parser::Choice(Choice {
                options,
                default,
                after_default,
            })),
            None,
        )
    }

    pub fn remove_conflicts(&self, builder: &ParserBuilder, depth: usize) -> Parser {
        if depth == 64 {
            panic!("Failed to reduce conflicts after 64 iterations")
        }
        let mut intersects = HashMap::<String, HashSet<usize>>::new();
        for (x, x_parser) in self.options.iter().enumerate() {
            let x_items = x_parser.start_tokens(builder);
            for (y, y_parser) in self.options.iter().enumerate() {
                if x >= y {
                    continue;
                }
                let y_items = y_parser.start_tokens(builder);
                let inter = x_items.intersection(&y_items).collect::<Vec<_>>();
                for item in inter {
                    let set = if let Some(existing) = intersects.get_mut(item) {
                        existing
                    } else {
                        intersects.insert(item.clone(), HashSet::new());
                        intersects.get_mut(item).unwrap()
                    };
                    set.insert(x);
                    set.insert(y);
                }
            }
        }
        if intersects.is_empty() {
            return Parser::Choice(self.clone());
        }

        let tokens = self.start_tokens(builder);
        let res = tokens
            .iter()
            .flat_map(|token| {
                let (after, _) = self.after_token(token, builder);
                after.map(|it| seq(vec![just(token.clone()), it]))
            })
            .collect::<Vec<_>>();

        Parser::Checkpoint(Checkpoint(Box::new(choice(res))))
    }
}

pub fn choice(options: Vec<Parser>) -> Parser {
    Parser::Choice(Choice {
        options,
        default: None,
        after_default: vec![],
    })
}

#[cfg(test)]
mod conflict_tests {

    use gibberish_core::{lang::Lang, node::Node};
    use gibberish_dyn_lib::bindings::{lang::CompiledLang, parse};
    use serial_test::serial;

    use crate::{assert_syntax_kind, assert_token_kind, parser::tests::build_test_parser};

    fn parse_test(text: &str) -> (CompiledLang, Node<CompiledLang>) {
        let parser = r#"keyword define;
        keyword table;
        keyword field;
        token whitespace = "\\s+";
        parser def_table = define + table;
        parser def_field = define + field;
        parser _def = (def_table | def_field).skip(whitespace);
        parser root = _def
        "#;
        let lang = build_test_parser(parser);
        let node = parse(&lang, text);
        (lang, node)
    }

    #[serial]
    #[test]
    fn test_def_table() {
        let (lang, node) = parse_test("define table");
        node.debug_print(true, true, &lang);

        assert_syntax_kind!(lang, node, root);
        let children = &node.as_group().children;
        assert_eq!(
            children.len(),
            1,
            "Expected 1 children but got {:#?}",
            node.as_group().children
        );

        assert_syntax_kind!(lang, &children[0], def_table);

        let children = &children[0].as_group().children;
        assert_eq!(
            children.len(),
            3,
            "Expected 3 children but got {:#?}",
            node.as_group().children
        );

        assert_token_kind!(lang, &children[0], define);
        assert_token_kind!(lang, &children[1], whitespace);
        assert_token_kind!(lang, &children[2], table);
    }

    #[serial]
    #[test]
    fn test_def_field() {
        let (lang, node) = parse_test("define field");
        node.debug_print(true, true, &lang);

        assert_syntax_kind!(lang, node, root);
        let children = &node.as_group().children;
        assert_eq!(
            children.len(),
            1,
            "Expected 1 children but got {:#?}",
            node.as_group().children
        );

        assert_syntax_kind!(lang, &children[0], def_field);

        let children = &children[0].as_group().children;
        assert_eq!(
            children.len(),
            3,
            "Expected 3 children but got {:#?}",
            node.as_group().children
        );

        assert_token_kind!(lang, &children[0], define);
        assert_token_kind!(lang, &children[1], whitespace);
        assert_token_kind!(lang, &children[2], field);
    }

    // TODO: If all options in a choice with conflicts has is named, when no
    // options match it should be grouped as unmatched

    // #[serial]
    // #[test]
    // fn test_unmatched() {
    //     let (lang, node) = parse_test("define");
    //     node.debug_print(true, true, &lang);
    //
    //     assert_syntax_kind!(lang, node, root);
    //     let children = &node.as_group().children;
    //     assert_eq!(
    //         children.len(),
    //         1,
    //         "Expected 1 children but got {:#?}",
    //         node.as_group().children
    //     );
    //
    //     assert_syntax_kind!(lang, &children[0], unmatched);
    //
    //     let children = &children[0].as_group().children;
    //     assert_eq!(
    //         children.len(),
    //         2,
    //         "Expected 3 children but got {:#?}",
    //         node.as_group().children
    //     );
    //
    //     assert_token_kind!(lang, &children[0], define);
    // }
}

#[cfg(test)]
mod param_conflicts_test {

    use gibberish_core::{lang::Lang, node::Node};
    use gibberish_dyn_lib::bindings::{lang::CompiledLang, parse};
    use serial_test::serial;

    use crate::{assert_syntax_kind, assert_token_kind, parser::tests::build_test_parser};

    fn parse_test(text: &str) -> (CompiledLang, Node<CompiledLang>) {
        let parser = r#"token num = "[0-9]+";
token whitespace = "\s+";
token comma = ",";
token plus = "\+";
token star = "\*";
token l_bracket = "\[";
token r_bracket = "\]";
token eq = "=";
token ident = "[_a-zA-Z][_a-zA-Z0-9]*";

parser atom = ident | num;
parser mul = atom fold (star + atom).repeated();
parser sum = mul fold (plus + mul).repeated();
parser _expr = sum;
parser param = ident + eq + _expr;
parser items = (param | sum).sep_by(comma);
parser _brackets = l_bracket + items + r_bracket;
parser root = _brackets.skip(whitespace)"#;
        let lang = build_test_parser(parser);
        let node = parse(&lang, text);
        (lang, node)
    }

    #[serial]
    #[test]
    fn test_ident() {
        let (lang, node) = parse_test("[hello]");
        node.debug_print(true, true, &lang);

        assert_syntax_kind!(lang, node, root);
        let children = &node.as_group().children;
        assert_eq!(
            children.len(),
            3,
            "Expected 1 children but got {:#?}",
            node.as_group().children
        );

        assert_token_kind!(lang, &children[0], l_bracket);
        assert_syntax_kind!(lang, &children[1], items);
        assert_token_kind!(lang, &children[2], r_bracket);

        let children = &children[1].as_group().children;
        assert_eq!(
            children.len(),
            1,
            "Expected 3 children but got {:#?}",
            children
        );

        assert_syntax_kind!(lang, &children[0], atom);

        let children = &children[0].as_group().children;
        assert_eq!(
            children.len(),
            1,
            "Expected 3 children but got {:#?}",
            node.as_group().children
        );

        assert_token_kind!(lang, &children[0], ident);
    }
}
