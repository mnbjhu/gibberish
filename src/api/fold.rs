use tracing::warn;

use crate::parser::{err::Expected, lang::Lang, res::PRes, state::ParserState};

use super::Parser;

#[derive(Debug, Clone)]
pub struct Fold<L: Lang> {
    name: L::Syntax,
    first: Box<Parser<L>>,
    next: Box<Parser<L>>,
}

impl<L: Lang> Fold<L> {
    pub fn parse(&self, state: &mut ParserState<L>, recover: bool) -> PRes {
        state.enter(self.name.clone());
        let first = self.first.do_parse(state, recover);
        if first.is_err() {
            warn!("Disolving name");
            state.disolve_name();
            return first;
        }
        if self.next.peak(state, recover, state.after_skip()).is_err() {
            warn!("Disolving name");
            state.disolve_name();
            return PRes::Ok;
        }
        loop {
            let next = self.next.do_parse(state, recover);
            if next.is_err() {
                if matches!(next, PRes::Break(_) | PRes::Eof) {
                    state.exit();
                    return PRes::Ok;
                }
                break;
            }
        }
        state.exit();
        PRes::Ok
    }

    pub fn peak(&self, state: &ParserState<L>, recover: bool, offset: usize) -> PRes {
        self.first.peak(state, recover, offset)
    }

    pub fn expected(&self) -> Vec<Expected<L>> {
        self.first.expected()
    }
}

impl<L: Lang> Parser<L> {
    pub fn fold(self, name: L::Syntax, next: Parser<L>) -> Parser<L> {
        Parser::Fold(Fold {
            name,
            first: Box::new(self),
            next: Box::new(next),
        })
    }
}

#[cfg(test)]
mod tests {
    use crate::{
        api::{Parser, just::just, seq::seq},
        json::{lang::JsonLang, lexer::JsonToken, syntax::JsonSyntax},
    };

    fn sum_parser() -> Parser<JsonLang> {
        let number: Parser<JsonLang> = just(JsonToken::Int).named(JsonSyntax::Number);
        number
            .clone()
            .fold(JsonSyntax::Add, seq(vec![just(JsonToken::Plus), number]))
    }

    #[test]
    fn test_add_op() {
        let res = sum_parser().parse("123 + 456");
        assert_eq!(res.name(), JsonSyntax::Root);
        assert_eq!(res.green_children().count(), 1);

        let sum = res.green_children().next().unwrap();
        assert_eq!(sum.name(), JsonSyntax::Add);
        assert_eq!(sum.green_children().count(), 2);

        for child in sum.green_children() {
            assert_eq!(child.name(), JsonSyntax::Number);
        }
    }

    #[test]
    fn test_disolve() {
        let res = sum_parser().parse("123");
        assert_eq!(res.name(), JsonSyntax::Root);
        assert_eq!(res.green_children().count(), 1);

        let sum = res.green_children().next().unwrap();
        assert_eq!(sum.name(), JsonSyntax::Number);
        assert_eq!(sum.green_children().count(), 0);
    }

    #[test]
    fn test_error_recover() {
        let res = sum_parser().parse("123 +");
        assert_eq!(res.name(), JsonSyntax::Root);
        assert_eq!(res.green_children().count(), 1);

        let sum = res.green_children().next().unwrap();
        assert_eq!(sum.name(), JsonSyntax::Add);
        assert_eq!(sum.green_children().count(), 1);

        for child in sum.green_children() {
            assert_eq!(child.name(), JsonSyntax::Number);
        }
    }
}
