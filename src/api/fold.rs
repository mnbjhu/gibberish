use tracing::debug;

use crate::{
    api::ptr::{ParserCache, ParserIndex},
    parser::{err::Expected, lang::Lang, res::PRes, state::ParserState},
};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Fold<L: Lang> {
    name: L::Syntax,
    first: ParserIndex<L>,
    next: ParserIndex<L>,
}

impl<'a, L: Lang> Fold<L> {
    pub fn parse(&'a self, state: &mut ParserState<'a, L>, recover: bool) -> PRes {
        state.enter(self.name.clone());
        let first = self.first.get_ref(state.cache).do_parse(state, recover);
        if first.is_err() {
            debug!("Disolving name");
            state.disolve_name();
            return first;
        }
        if self
            .next
            .get_ref(state.cache)
            .peak(state, recover, state.after_skip())
            .is_err()
        {
            debug!("Disolving name");
            state.disolve_name();
            return PRes::Ok;
        }
        loop {
            let next = self.next.get_ref(state.cache).do_parse(state, recover);
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
        self.first.get_ref(state.cache).peak(state, recover, offset)
    }

    pub fn expected(&self, state: &ParserState<'a, L>) -> Vec<Expected<L>> {
        self.first.get_ref(state.cache).expected(state)
    }
}

impl<L: Lang> ParserIndex<L> {
    pub fn fold(
        self,
        name: L::Syntax,
        next: ParserIndex<L>,
        cache: &mut ParserCache<L>,
    ) -> ParserIndex<L> {
        Parser::Fold(Fold {
            name,
            first: self,
            next,
        })
        .cache(cache)
    }
}

#[cfg(test)]
mod tests {
    use crate::{
        api::{
            just::just,
            ptr::{ParserCache, ParserIndex},
            seq::seq,
        },
        json::{lang::JsonLang, lexer::JsonToken, syntax::JsonSyntax},
    };

    fn sum_parser(cache: &mut ParserCache<JsonLang>) -> ParserIndex<JsonLang> {
        let number = just(JsonToken::Int, cache).named(JsonSyntax::Number, cache);
        number.clone().fold(
            JsonSyntax::Add,
            seq(vec![just(JsonToken::Plus, cache), number], cache),
            cache,
        )
    }

    #[test]
    fn test_add_op() {
        let mut cache = ParserCache::new(JsonLang);
        let res = sum_parser(&mut cache).parse("123 + 456", &cache);
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
        let mut cache = ParserCache::new(JsonLang);
        let res = sum_parser(&mut cache).parse("123", &cache);
        assert_eq!(res.name(), JsonSyntax::Root);
        assert_eq!(res.green_children().count(), 1);

        let sum = res.green_children().next().unwrap();
        assert_eq!(sum.name(), JsonSyntax::Number);
        assert_eq!(sum.green_children().count(), 0);
    }

    #[test]
    fn test_error_recover() {
        let mut cache = ParserCache::new(JsonLang);
        let res = sum_parser(&mut cache).parse("123 +", &cache);
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
