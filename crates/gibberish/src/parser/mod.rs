pub mod err;
pub mod lang;
pub mod node;
pub mod res;
pub mod state;

// macro_rules! parser {
//     // List form: second arg is [A, B, C, ...] where each item is any expr.
//     ($lang:ident, $cache:expr, [$($p:expr),+ $(,)?]) => {
//         $crate::api::seq::seq(vec![$( parser!($lang, $cache, $p) ),+], $cache)
//     };
//
//     // Simple form: identifiers for lang and parser.
//     ($lang:ident, $cache:expr, $parser:ident) => {
//         $crate::api::just::just($lang::$parser, $cache)
//     };
// }
//
// #[cfg(test)]
// mod tests {
//     use crate::api::Parser;
//     use crate::api::ptr::{ParserCache, ParserIndex};
//     use crate::json::lang::JsonLang;
//     use crate::json::lexer::JsonToken;
//     use crate::parser::lang::Lang;
//
//     #[test]
//     fn test() {
//         let mut cache = ParserCache::new();
//         let parser: ParserIndex<JsonLang> = parser!(JsonToken, &mut cache, [String, String]);
//     }
// }
