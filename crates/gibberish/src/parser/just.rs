use std::{collections::HashSet, fmt::Display};

use gibberish_core::{err::Expected, lang::RawLang};

use crate::ast::builder::ParserBuilder;

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Just(pub String);

impl Just {
    pub fn expected(&self, builder: &ParserBuilder) -> Vec<Expected<RawLang>> {
        let token_id = builder
            .lexer
            .iter()
            .position(|(it, _)| it == &self.0)
            .unwrap();
        vec![Expected::Token(token_id as u32)]
    }

    pub fn build_parse(&self, id: usize, builder: &ParserBuilder, f: &mut impl std::fmt::Write) {
        let kind = builder.get_token_id(&self.0);

        // C version of "Parse Just"
        // Return convention preserved from QBE:
        //   0 => ok (token consumed)
        //   1 => error
        //   2 => eof
        //   >=3 => break code (index + 3)
        write!(
            f,
            r#"

/* Parse Just */
static size_t parse_{id}(ParserState *state, size_t unmatched_checkpoint) {{
    (void)unmatched_checkpoint;

    for (;;) {{
        /* EOF */
        if (state->offset >= state->tokens.len) {{
            return 2;
        }}

        uint32_t current = current_kind(state);

        /* Match expected token */
        if (current == (uint32_t){kind}) {{
            bump(state);
            return 0;
        }}

        /* Skip token if configured */
        if (skipped_vec_contains(&state->skipped, current)) {{
            bump_skipped(state);
            continue;
        }}

        /* Mismatch */
        break;
    }}

    /* Recovery: walk break stack from top to bottom.
       If any PeakFunc matches, return (index + 3) like QBE. */
    size_t index = state->breaks.len;
    while (index != 0) {{
        index -= 1;
        PeakFunc pf = state->breaks.data[index];
        if (pf && pf(state)) {{
            return index + 3;
        }}
    }}

    return 1;
}}
"#,
            id = id,
            kind = kind
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
    Parser::Just(Just(tok))
}

impl Display for Just {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.0)
    }
}

#[cfg(test)]
mod tests {
    use gibberish_core::{lang::Lang, node::Node};
    use gibberish_dyn_lib::bindings::{lang::CompiledLang, parse};
    use serial_test::serial;

    use crate::parser::tests::build_test_parser;

    fn parse_just_test(text: &str) -> (CompiledLang, Node<CompiledLang>) {
        let parser = r#"token num = "[0-9]+";
        token whitespace = "\s+";
        parser root = num"#;
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
        parser root = just"#;
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
