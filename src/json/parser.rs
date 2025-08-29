use crate::api::{Parser, choice::choice, just::just, rec::recursive, seq::seq};

use super::{lang::JsonLang, lexer::JsonToken};

fn json_parser() -> Parser<JsonLang> {
    recursive(|e| {
        let string = just(JsonToken::String).named(JsonToken::String);
        let int = just(JsonToken::Int).named(JsonToken::Number);

        let arr = e
            .clone()
            .sep_by(JsonToken::Comma)
            .delim_by(JsonToken::LBracket, JsonToken::RBracket)
            .named(JsonToken::Array);

        let obj_field = seq(vec![
            just(JsonToken::String).named(JsonToken::Key),
            just(JsonToken::Colon),
            e,
        ])
        .named(JsonToken::Field);

        let obj = obj_field
            .sep_by(JsonToken::Comma)
            .delim_by(JsonToken::LBrace, JsonToken::RBrace)
            .named(JsonToken::Object);
        let atom = choice(vec![obj, arr, string, int]);

        atom.clone()
            .fold(JsonToken::Add, seq(vec![just(JsonToken::Plus), atom]))
    })
}

// #[cfg(test)]
// mod tests {
//     use crate::{
//         json::{parser::json_parser, syntax::JsonSyntax},
//         parser::node::{Group, Node},
//     };
//
//     #[test]
//     fn test_parse_string() {
//         let input = r#""Test""#;
//         let root = json_parser().parse(input);
//         if let Node::Group(Group { kind, children, .. }) = root {
//             assert_eq!(kind, JsonSyntax::Root);
//             assert_eq!(children.len(), 1, "Expected a single child");
//             if let Node::Group(Group { kind, .. }) = &children[0] {
//                 assert_eq!(kind, &JsonSyntax::String)
//             }
//         } else {
//             panic!("Expected group root")
//         }
//     }
//
//     #[test]
//     fn test_parse_array() {
//         let input = r#"["Test"]"#;
//         let root = json_parser().parse(input);
//         assert_eq!(root.name(), JsonSyntax::Root);
//         assert_eq!(root.green_children().count(), 1, "Expected a single child");
//
//         let arr = root.green_children().next().unwrap();
//         assert_eq!(arr.name(), JsonSyntax::Array);
//
//         let child = arr.green_children().next().unwrap();
//         assert_eq!(child.name(), JsonSyntax::String);
//     }
//
//     #[test]
//     fn test_parse_array_2() {
//         let input = r#"[123, 456]"#;
//         let root = json_parser().parse(input);
//         assert_eq!(root.name(), JsonSyntax::Root);
//         assert_eq!(root.green_children().count(), 1, "Expected a single child");
//
//         let arr = root.green_children().next().unwrap();
//         assert_eq!(arr.name(), JsonSyntax::Array);
//         assert_eq!(arr.green_children().count(), 2, "Expected two children");
//
//         let mut elements = arr.green_children();
//
//         let first = elements.next().unwrap();
//         assert_eq!(first.name(), JsonSyntax::Number);
//
//         let second = elements.next().unwrap();
//         assert_eq!(second.name(), JsonSyntax::Number);
//     }
//
//     #[test]
//     fn test_parse_obj() {
//         let input = r#"{"thing": 123}"#;
//         let root = json_parser().parse(input);
//         assert_eq!(root.name(), JsonSyntax::Root);
//         assert_eq!(root.green_children().count(), 1, "Expected a single child");
//
//         let obj = root.green_children().next().unwrap();
//         assert_eq!(obj.name(), JsonSyntax::Object);
//         assert_eq!(obj.green_children().count(), 1, "Expected a single child");
//
//         let field = obj.green_children().next().unwrap();
//         assert_eq!(field.name(), JsonSyntax::Field);
//         assert_eq!(field.green_children().count(), 2, "Expected two children");
//
//         let mut kv = field.green_children();
//
//         let key = kv.next().unwrap();
//         assert_eq!(key.name(), JsonSyntax::Key);
//
//         let value = kv.next().unwrap();
//         assert_eq!(value.name(), JsonSyntax::Number)
//     }
//
//     #[test]
//     fn test_sum_in_arr_with_err() {
//         let input = r#"[123 +]"#;
//         let root = json_parser().parse(input);
//         assert_eq!(root.name(), JsonSyntax::Root);
//         assert_eq!(root.green_children().count(), 1, "Expected a single child");
//
//         let arr = root.green_children().next().unwrap();
//         assert_eq!(arr.name(), JsonSyntax::Array);
//         assert_eq!(arr.green_children().count(), 1, "Expected a single child");
//         assert_eq!(arr.errors().count(), 0);
//
//         let sum = arr.green_children().next().unwrap();
//         assert_eq!(sum.name(), JsonSyntax::Add);
//         assert_eq!(sum.green_children().count(), 1, "Expected a single child");
//
//         assert_eq!(sum.errors().count(), 1);
//
//         let num = sum.green_children().next().unwrap();
//         assert_eq!(num.errors().count(), 0);
//         assert_eq!(num.name(), JsonSyntax::Number);
//         assert_eq!(num.green_children().count(), 0, "Expected no children");
//     }
//
//     #[test]
//     fn test_missing_expression() {
//         let input = r#"[123,]"#;
//         let root = json_parser().parse(input);
//         assert_eq!(root.name(), JsonSyntax::Root);
//         assert_eq!(root.green_children().count(), 1, "Expected a single child");
//
//         let arr = root.green_children().next().unwrap();
//         assert_eq!(arr.name(), JsonSyntax::Array);
//         assert_eq!(arr.green_children().count(), 1, "Expected a single child");
//
//         assert_eq!(arr.errors().count(), 1);
//
//         let num = arr.green_children().next().unwrap();
//         assert_eq!(num.errors().count(), 0);
//         assert_eq!(num.name(), JsonSyntax::Number);
//         assert_eq!(num.green_children().count(), 0, "Expected no children");
//     }
//
//     #[test]
//     fn test_invalid_sep() {
//         let input = r#"[123 "abc"]"#;
//         let root = json_parser().parse(input);
//         assert_eq!(root.name(), JsonSyntax::Root);
//         assert_eq!(root.green_children().count(), 1, "Expected a single child");
//
//         let arr = root.green_children().next().unwrap();
//         assert_eq!(arr.name(), JsonSyntax::Array);
//         assert_eq!(arr.green_children().count(), 1, "Expected a single child");
//         assert_eq!(arr.errors().count(), 1);
//
//         assert_eq!(arr.errors().count(), 1);
//         let error = arr.errors().next().unwrap();
//         assert_eq!(error.actual.len(), 1);
//
//         let num = arr.green_children().next().unwrap();
//         assert_eq!(num.errors().count(), 0);
//         assert_eq!(num.name(), JsonSyntax::Number);
//         assert_eq!(num.green_children().count(), 0, "Expected no children");
//     }
// }
