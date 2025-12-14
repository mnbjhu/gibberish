use std::{
    collections::{HashMap, HashSet},
    fmt::Display,
};

use gibberish_core::{err::Expected, lang::CompiledLang};
use tracing::info;

use crate::{
    ast::builder::ParserBuilder,
    parser::{checkpoint::Checkpoint, just::just, seq::seq},
};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Choice {
    pub options: Vec<Parser>,
    pub default: Option<String>,
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
            write!(f, " : {d}")?
        }
        write!(f, ")")
    }
}

impl Choice {
    pub fn expected(&self, builder: &ParserBuilder) -> Vec<Expected<CompiledLang>> {
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
        let ret_err = match &self.default {
            Some(d) if d == "%group_at_default%" => &format!(
                "\n@ret_err
    call $group_at(l %state_ptr, w {default}, l %unmatched_checkpoint)
    ret %res
",
                default = builder.vars.len() + 1
            ),
            Some(default) => {
                let default = builder.get_group_id(default);
                &format!(
                    "\n@ret_err
    call $group_at(l %state_ptr, w {default}, l %unmatched_checkpoint)
    ret %res
",
                )
            }
            None => {
                "\n@ret_err
    ret %res
"
            }
        };
        write!(
            f,
            "
# Build Choice
function l $parse_{id}(l %state_ptr, w %recover, l %unmatched_checkpoint) {{",
        )
        .unwrap();
        for (index, option) in options.iter().enumerate() {
            let next = if index + 1 == options.len() {
                "@ret_err"
            } else {
                &format!("@check_{}", index + 1)
            };
            write!(
                f,
                "
@check_{index}
    %res =l call $parse_{option}(l %state_ptr, w %recover, l %unmatched_checkpoint)
    jnz %res, {next}, @ret",
            )
            .unwrap();
        }
        write!(
            f,
            "
@ret
    ret %res
{ret_err}
}}"
        )
        .unwrap();
    }

    pub fn start_tokens(&self, builder: &ParserBuilder) -> HashSet<String> {
        let mut set = HashSet::new();
        for option in &self.options {
            set.extend(option.start_tokens(builder));
        }
        set
    }

    pub fn is_optional(&self, _: &ParserBuilder) -> bool {
        false // TODO: Look into whether this is easy to support
    }

    pub fn after_token(&self, token: &str, builder: &mut ParserBuilder) -> Option<Parser> {
        let mut parsers = vec![];
        for (index, p) in self.options.iter().enumerate() {
            if p.start_tokens(builder).contains(token) {
                parsers.push(index);
            }
        }
        if parsers.is_empty() {
            panic!()
        } else if parsers.len() == 1 {
            return self.options[parsers[0]].clone().after_token(token, builder);
        }
        let require_named = self.options.iter().all(|it| matches!(it, Parser::Named(_)));
        let mut default = None;
        let rest = parsers
            .iter()
            .filter_map(|index| {
                if let Some(rest) = self.options[*index].clone().after_token(token, builder) {
                    Some(rest)
                } else {
                    if require_named {
                        let name = self.options[*index].get_name(&builder).unwrap();
                        if default.is_none() {
                            default = Some(name);
                        } else {
                            panic!("Expected named")
                        }
                    }
                    None
                }
            })
            .collect::<Vec<_>>();
        if default.is_none() {
            default = Some("%group_at_default%".to_string());
        }
        let option = if rest.is_empty() {
            panic!("Found 0 intersect");
        } else {
            seq(vec![
                just(token.to_string()),
                Parser::Choice(Choice {
                    options: rest,
                    default,
                }),
            ])
        };
        Some(option)
    }

    pub fn remove_conflicts(&self, builder: &mut ParserBuilder, depth: usize) -> Parser {
        // println!("Reducing conflicts");
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
            // println!("Found no conflicts");
            return Parser::Choice(self.clone());
        }

        // println!("Reducing intersects {self:?}: {intersects:?}");
        let has_named = self.options.iter().any(|it| matches!(it, Parser::Named(_)));
        // let require_named = self.options.iter().all(|it| matches!(it, Parser::Named(_)));
        let mut options = Vec::new();
        for (token, _) in intersects {
            let option = self.after_token(token.as_str(), builder).unwrap(); // TODO: Check
            options.push(option);
        }
        for item in &self.options {
            options.push(item.clone());
        }
        let p = choice(options);
        info!("Done");
        if has_named {
            Parser::Checkpoint(Checkpoint(Box::new(p)))
        } else {
            p
        }
    }
}

pub fn choice(options: Vec<Parser>) -> Parser {
    Parser::Choice(Choice {
        options,
        default: None,
    })
}

#[cfg(test)]
mod conflict_tests {

    use gibberish_core::{
        lang::{CompiledLang, Lang},
        node::Node,
    };
    use gibberish_dyn_lib::bindings::parse;
    use serial_test::serial;

    use crate::{assert_syntax_kind, assert_token_kind, parser::tests::build_test_parser};

    fn parse_test(text: &str) -> (CompiledLang, Node<CompiledLang>) {
        let parser = r#"keyword define;
        keyword table;
        keyword field;
        token whitespace = "\\s+";
        parser def_table = define + table;
        parser def_field = define + field;
        parser _def = (def_table | def_field).skip(whitespace)
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
}
