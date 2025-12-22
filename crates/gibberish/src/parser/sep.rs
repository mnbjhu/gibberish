use std::{collections::HashSet, fmt::Display};

use gibberish_core::{err::Expected, lang::RawLang};

use crate::ast::builder::ParserBuilder;

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Sep {
    pub sep: Box<Parser>,
    pub item: Box<Parser>,
    pub at_least: usize,
}

impl Sep {
    pub fn expected(&self, builder: &ParserBuilder) -> Vec<Expected<RawLang>> {
        self.item.expected(builder)
    }

    pub fn build_parse(
        &self,
        id: usize,
        builder: &mut ParserBuilder,
        f: &mut impl std::fmt::Write,
    ) {
        let sep = self.sep.build(builder, f);
        let item = self.item.build(builder, f);

        // PeakFunc wrappers because PeakFunc is bool (*)(ParserState*),
        // while peak_{x} is bool peak_{x}(ParserState*, size_t, bool)
        writeln!(
            f,
            r#"
/* Sep break predicate wrapper: item */
static bool break_pred_sep_{id}_item(ParserState *state) {{
    return peak_{item}(state, 0, false);
}}

/* Sep break predicate wrapper: sep */
static bool break_pred_sep_{id}_sep(ParserState *state) {{
    return peak_{sep}(state, 0, false);
}}
"#,
        )
        .unwrap();

        writeln!(
            f,
            r#"
/* Parse Sep */
static size_t parse_{id}(ParserState *state, size_t unmatched_checkpoint) {{
    /* Push break predicates: item then sep (sep ends up on top, like your old push order). */
    size_t item_brk = push_break(state, break_pred_sep_{id}_item);
    size_t sep_brk  = push_break(state, break_pred_sep_{id}_sep);

    size_t res = 0;

    res = parse_{item}(state, unmatched_checkpoint);

    if (res != 0) {{
        /* error / eof / break: match old behavior -> propagate */
        goto ret_err;
    }}

    /* ---- loop: (sep item)* ---- */
    for (;;) {{
        /* Try parse sep */
        for (;;) {{
            res = parse_{sep}(state, unmatched_checkpoint);
            if (res == 1) {{
                bump_err(state);
                continue;
            }}
            break;
        }}

        if (res == 0) {{
            /* parsed sep, now must parse item */
        }} else {{
            /* couldn't parse sep */
            if (res == 2) {{
                /* EOF while expecting sep: success */
                goto ret_ok;
            }}

            if (res == item_brk) {{
                /* We hit an item delimiter => missing separator */
                ExpectedVec e = expected_{sep}();
                missing(state, e);
                /* then attempt item */
            }} else {{
                /* some other break or error => stop successfully (old QBE ret_ok) */
                goto ret_ok;
            }}
        }}

        /* Try parse item */
        for (;;) {{
            res = parse_{item}(state, unmatched_checkpoint);
            if (res == 1) {{
                bump_err(state);
                continue;
            }}
            break;
        }}

        if (res == 0) {{
            /* got item, continue looping */
            continue;
        }}

        /* item didn't parse */
        {{
            /* Always emit missing(item) on failure (matches old QBE check_item_eof path) */
            ExpectedVec e = expected_{item}();
            missing(state, e);

            if (res == 2) {{
                /* EOF after missing item: success */
                goto ret_ok;
            }}

            if (res == sep_brk) {{
                /* We hit a sep delimiter => treat missing item as recovery and continue with sep */
                continue;
            }}

            /* Otherwise: stop successfully */
            goto ret_ok;
        }}
    }}

ret_ok:
    /* pop sep break then item break */
    (void)break_stack_pop(&state->breaks, NULL);
    (void)break_stack_pop(&state->breaks, NULL);
    return 0;

ret_err:
    (void)break_stack_pop(&state->breaks, NULL);
    (void)break_stack_pop(&state->breaks, NULL);
    return res;
}}
"#,
            id = id,
            sep = sep,
            item = item
        )
        .unwrap();
    }

    pub fn start_tokens(&self, cache: &ParserBuilder) -> HashSet<String> {
        self.item.start_tokens(cache)
    }

    pub fn is_optional(&self, _: &ParserBuilder) -> bool {
        false // TODO: Fix
    }
    pub fn remove_conflicts(&self, builder: &ParserBuilder, depth: usize) -> Parser {
        self.item
            .remove_conflicts(builder, depth)
            .sep_by(self.sep.remove_conflicts(builder, depth))
    }
}

impl Display for Sep {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}.sep_by({})", self.item, self.sep)
    }
}

impl Parser {
    pub fn sep_by(self, sep: Parser) -> Parser {
        Parser::Sep(Sep {
            item: Box::new(self),
            sep: Box::new(sep),
            at_least: 0,
        })
    }
}

#[cfg(test)]
mod tests {
    use gibberish_core::{
        err::{Expected, ParseError},
        lang::Lang,
        node::Node,
    };
    use gibberish_dyn_lib::bindings::{lang::CompiledLang, parse};
    use serial_test::serial;

    use crate::{assert_syntax_kind, assert_token_kind, parser::tests::build_test_parser};

    fn parse_sep_test(text: &str) -> (CompiledLang, Node<CompiledLang>) {
        let parser = r#"token num = "[0-9]+";
        token whitespace = "\s+";
        token comma = ",";
        parser root = num.sep_by(comma)
        "#;
        let lang = build_test_parser(parser);
        let node = parse(&lang, text);
        (lang, node)
    }

    #[serial]
    #[test]
    fn test_single() {
        let (lang, node) = parse_sep_test("123");
        assert_syntax_kind!(lang, node, root);
        let children = &node.as_group().children;
        assert_eq!(children.len(), 1);
        assert_token_kind!(lang, &children[0], num);
    }

    #[serial]
    #[test]
    fn test_empty() {
        let (lang, node) = parse_sep_test("");
        assert_syntax_kind!(lang, node, root);
        let children = &node.as_group().children;
        assert_eq!(children.len(), 1);
        let Node::Err(ParseError::MissingError { expected, .. }) = &children[0] else {
            panic!(
                "Expected the last node to be a missing error but got {:?}",
                &children[0]
            )
        };
        assert_eq!(expected.len(), 1);
        let Expected::Token(t) = &expected[0] else {
            panic!("Expected a missing token");
        };
        assert_eq!(lang.token_name(t), "num");
    }

    #[serial]
    #[test]
    fn test_multi() {
        let (lang, node) = parse_sep_test("123,123");
        assert_syntax_kind!(lang, node, root);
        let children = &node.as_group().children;
        assert_eq!(children.len(), 3);
        assert_token_kind!(lang, &children[0], num);
        assert_token_kind!(lang, &children[1], comma);
        assert_token_kind!(lang, &children[2], num);
    }

    #[serial]
    #[test]
    fn test_missing_last() {
        let (lang, node) = parse_sep_test("123,");
        assert_syntax_kind!(lang, node, root);
        let children = &node.as_group().children;
        assert_eq!(children.len(), 3);
        assert_token_kind!(lang, &children[0], num);
        assert_token_kind!(lang, &children[1], comma);
        let Node::Err(ParseError::MissingError { expected, .. }) = &children[2] else {
            panic!(
                "Expected the last node to be a missing error but got {:?}",
                &children[2]
            )
        };
        assert_eq!(expected.len(), 1);
        let Expected::Token(t) = &expected[0] else {
            panic!("Expected a missing token");
        };
        assert_eq!(lang.token_name(t), "num");
    }

    #[serial]
    #[test]
    fn test_missing_between() {
        let (lang, node) = parse_sep_test("123,,123");
        assert_syntax_kind!(lang, node, root);
        let children = &node.as_group().children;
        assert_eq!(children.len(), 5);
        assert_token_kind!(lang, &children[0], num);
        assert_token_kind!(lang, &children[1], comma);
        assert_token_kind!(lang, &children[3], comma);
        assert_token_kind!(lang, &children[4], num);
        let Node::Err(ParseError::MissingError { expected, .. }) = &children[2] else {
            panic!(
                "Expected the middle node to be a missing error but got {:?}",
                &children[2]
            )
        };
        assert_eq!(expected.len(), 1);
        let Expected::Token(t) = &expected[0] else {
            panic!("Expected a missing token");
        };
        assert_eq!(lang.token_name(t), "num");
    }
}
