use crate::runtime::lexer::pos::Pos;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Tok {
    pub kind: u32,
    pub lookahead: usize,
    pub relative_pos: Pos,
}
