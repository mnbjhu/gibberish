use crate::dsl::{Parser, choice::choice, just::just, rec::recursive, seq::seq};

use super::{lang::JsonLang, lexer::JsonToken, syntax::JsonSyntax};

pub fn json_parser() -> Parser<JsonLang> {
    recursive(|e| {
        let string = just(JsonToken::String).named(JsonSyntax::String);
        let int = just(JsonToken::Int).named(JsonSyntax::Number);

        let arr = e
            .clone()
            .sep_by(just(JsonToken::Comma))
            .delim_by(just(JsonToken::LBracket), just(JsonToken::RBracket))
            .named(JsonSyntax::Array);

        let obj_field = seq(vec![
            just(JsonToken::String).named(JsonSyntax::Key),
            just(JsonToken::Colon),
            e,
        ])
        .named(JsonSyntax::Field);

        let obj = obj_field
            .sep_by(just(JsonToken::Comma))
            .delim_by(just(JsonToken::LBrace), just(JsonToken::RBrace))
            .named(JsonSyntax::Object);
        let atom = choice(vec![obj, arr, string, int]);

        atom.clone()
            .fold(JsonSyntax::Add, seq(vec![just(JsonToken::Plus), atom]))
    })
}

#[cfg(test)]
mod tests {
    use crate::{
        json::{lang::JsonLang, syntax::JsonSyntax},
        parser::{
            lang::Lang,
            node::{Group, Node},
        },
    };

    #[test]
    fn test_parse_string() {
        let input = r#""Test""#;
        let root = JsonLang::parse(input);
        if let Node::Group(Group { kind, children, .. }) = root {
            assert_eq!(kind, JsonSyntax::Root);
            assert_eq!(children.len(), 1, "Expected a single child");
            if let Node::Group(Group { kind, .. }) = &children[0] {
                assert_eq!(kind, &JsonSyntax::String)
            }
        } else {
            panic!("Expected group root")
        }
    }

    #[test]
    fn test_parse_array() {
        let input = r#"["Test"]"#;
        let root = JsonLang::parse(input);
        assert_eq!(root.name(), JsonSyntax::Root);
        assert_eq!(root.green_children().count(), 1, "Expected a single child");

        let arr = root.green_children().next().unwrap();
        assert_eq!(arr.name(), JsonSyntax::Array);

        let child = arr.green_children().next().unwrap();
        assert_eq!(child.name(), JsonSyntax::String);
    }

    #[test]
    fn test_parse_array_2() {
        let input = r#"[123, 456]"#;
        let root = JsonLang::parse(input);
        assert_eq!(root.name(), JsonSyntax::Root);
        assert_eq!(root.green_children().count(), 1, "Expected a single child");

        let arr = root.green_children().next().unwrap();
        assert_eq!(arr.name(), JsonSyntax::Array);
        assert_eq!(arr.green_children().count(), 2, "Expected two children");

        let mut elements = arr.green_children();

        let first = elements.next().unwrap();
        assert_eq!(first.name(), JsonSyntax::Number);

        let second = elements.next().unwrap();
        assert_eq!(second.name(), JsonSyntax::Number);
    }

    #[test]
    fn test_parse_obj() {
        let input = r#"{"thing": 123}"#;
        let root = JsonLang::parse(input);
        assert_eq!(root.name(), JsonSyntax::Root);
        assert_eq!(root.green_children().count(), 1, "Expected a single child");

        let obj = root.green_children().next().unwrap();
        assert_eq!(obj.name(), JsonSyntax::Object);
        assert_eq!(obj.green_children().count(), 1, "Expected a single child");

        let field = obj.green_children().next().unwrap();
        assert_eq!(field.name(), JsonSyntax::Field);
        assert_eq!(field.green_children().count(), 2, "Expected two children");

        let mut kv = field.green_children();

        let key = kv.next().unwrap();
        assert_eq!(key.name(), JsonSyntax::Key);

        let value = kv.next().unwrap();
        assert_eq!(value.name(), JsonSyntax::Number)
    }
}
