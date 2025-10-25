use crate::parser::{err::Expected, lang::Lang, res::PRes, state::ParserState};

pub trait CustomParser<L: Lang>: std::fmt::Debug {
    fn parse(&self, state: &mut ParserState<L>, recover: bool) -> PRes;

    fn peak(&self, state: &ParserState<L>, recover: bool, offset: usize) -> PRes;

    fn expected(&self) -> Vec<Expected<L>>;

    fn name(&self) -> String;
}
