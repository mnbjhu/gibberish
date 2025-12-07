use std::collections::HashSet;

use gibberish_core::{err::Expected, lang::CompiledLang};

use crate::{
    ast::try_parse,
    parser::ptr::{ParserCache, ParserIndex},
};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Sep {
    pub sep: ParserIndex,
    pub item: ParserIndex,
    pub at_least: usize,
}

impl Sep {
    pub fn expected(&self, cache: &ParserCache) -> Vec<Expected<CompiledLang>> {
        self.item.get_ref(cache).expected(cache)
    }

    pub fn build_parse(&self, id: usize, f: &mut impl std::fmt::Write) {
        write!(
            f,
            "
# Parse Sep
function w $parse_{id}(l %state_ptr, w %recover, l %unmatched_checkpoint) {{
@start
    %item_index =l call $push_delim(l %state_ptr, l {item})
    %sep_index =l call $push_delim(l %state_ptr, l {sep})
    %res =l call $parse_{item}(l %state_ptr, w %recover, l %unmatched_checkpoint)
    jnz %res, @ret_err, @try_parse_sep
@check_sep
    jnz %res, @check_sep_eof, @try_parse_item
@check_sep_eof
    %is_eof =w ceql %res, 2
    jnz %is_eof, @ret_ok, @sep_check_item_delim
@sep_check_item_delim
    %is_item =w ceql %item_index, %res
    jnz %is_item, @missing_sep, @ret_ok
@missing_sep
    %expected =:vec call $expected_{sep}()
    call $missing(l %state_ptr, l %expected)
    jmp @try_parse_item
@check_item
    jnz %res, @check_item_eof, @try_parse_sep
@check_item_eof
    %expected =:vec call $expected_{item}()
    call $missing(l %state_ptr, l %expected)
    %is_eof =w ceql %res, 2
    jnz %is_eof, @ret_ok, @item_check_sep_delim
@item_check_sep_delim
    %is_sep =w ceql %sep_index, %res
    jnz %is_sep, @try_parse_sep, @ret_ok
",
            sep = self.sep.index,
            item = self.item.index,
        )
        .unwrap();
        try_parse(self.sep.index, "sep", "@check_sep", f);
        try_parse(self.item.index, "item", "@check_item", f);
        write!(
            f,
            "
@ret_ok
    call $pop_delim(l %state_ptr)
    call $pop_delim(l %state_ptr)
    ret 0
@ret_err
    call $pop_delim(l %state_ptr)
    call $pop_delim(l %state_ptr)
    ret %res
}}",
        )
        .unwrap()
    }

    pub fn start_tokens(&self, cache: &ParserCache) -> HashSet<u32> {
        self.item.get_ref(cache).start_tokens(cache)
    }

    pub fn is_optional(&self, cache: &ParserCache) -> bool {
        false // TODO: Fix
    }
}

impl ParserIndex {
    pub fn sep_by(self, sep: ParserIndex, cache: &mut ParserCache) -> ParserIndex {
        Parser::Sep(Sep {
            item: self,
            sep,
            at_least: 0,
        })
        .cache(cache)
    }

    pub fn sep_by_extra(
        self,
        sep: ParserIndex,
        at_least: usize,
        cache: &mut ParserCache,
    ) -> ParserIndex {
        Parser::Sep(Sep {
            item: self,
            sep,
            at_least,
        })
        .cache(cache)
    }
}

#[cfg(test)]
mod tests {
    use gibberish_core::{
        err::{Expected, ParseError},
        lang::{CompiledLang, Lang},
        node::Node,
    };
    use gibberish_dyn_lib::bindings::parse;
    use serial_test::serial;

    use crate::{assert_syntax_kind, assert_token_kind, parser::tests::build_test_parser};

    fn parse_sep_test(text: &str) -> (CompiledLang, Node<CompiledLang>) {
        let parser = r#"token num = "[0-9]+";
        token whitespace = "\s+";
        token comma = ",";
        parser _root = num.sep_by(comma)
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
