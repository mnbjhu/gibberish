#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Tok {
    pub kind: u32,
    pub len: usize,
    pub lookahead: usize,
    // pub relative_pos: Pos,
}
