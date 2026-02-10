use crate::runtime::parser::{Parser, state::State};

pub struct SeqParserState<'a, 't, 'state> {
    pub state: &'state mut State<'a, 't>,
    pub offset: &'state mut usize,
    pub parsers: &'a [&'a Parser],
    pub index: usize,
    pub last_item_break_index: usize,
}

impl<'a, 't, 'state> SeqParserState<'a, 't, 'state> {
    pub fn has_more(&self) -> bool {
        self.index < self.parsers.len()
    }

    pub fn next(&self, state: &mut State<'a, 't>) {}
}
