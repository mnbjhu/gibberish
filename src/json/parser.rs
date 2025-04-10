use crate::dsl::{Parser, choice::choice, just::just, rec::recursive};

use super::{lang::JsonLang, lexer::JsonToken, syntax::JsonSyntax};

pub fn json_parser() -> Parser<JsonLang> {
    recursive(|e| {
        let string = just(JsonToken::String).named(JsonSyntax::String);
        let int = just(JsonToken::Int).named(JsonSyntax::Number);
        let arr = e
            .sep_by(just(JsonToken::Comma))
            .delim_by(just(JsonToken::LBracket), just(JsonToken::RBracket))
            .named(JsonSyntax::Array);
        choice(vec![arr, string, int])
    })
}

#[cfg(test)]
mod tests {
    use crate::{
        json::{lang::JsonLang, syntax::JsonSyntax},
        parser::{lang::Lang, node::Node},
    };

    #[test]
    fn test_parse_string() {
        let input = r#""Test""#;
        let root = JsonLang::parse(input);
        if let Node::Group { kind, children, .. } = root {
            assert_eq!(kind, JsonSyntax::Root);
            assert_eq!(children.len(), 1, "Expected a single child");
            if let Node::Group { kind, .. } = &children[0] {
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
        if let Node::Group { kind, children, .. } = root {
            assert_eq!(kind, JsonSyntax::Root);
            assert_eq!(children.len(), 1, "Expected a single child");
            if let Node::Group { kind, children, .. } = &children[0] {
                assert_eq!(kind, &JsonSyntax::Array);
                assert_eq!(children.len(), 1, "Expected a single child");
                if let Node::Group { kind, .. } = &children[0] {
                    assert_eq!(kind, &JsonSyntax::String)
                }
            }
        } else {
            panic!("Expected group root")
        }
    }
}
