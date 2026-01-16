use crate::runtime::parser::{Parser, state::State};

pub struct SeqParserState<'a> {
    pub parsers: &'a [&'a Parser],
    pub index: usize,
    pub last_item_break_index: usize,
}

impl<'a> SeqParserState<'a> {
    pub fn has_more(&self) -> bool {
        self.index < self.parsers.len()
    }

    pub fn next<'t>(&self, state: &mut State<'a, 't>) {}
}
