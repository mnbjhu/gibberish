use crate::runtime::lexer::pos::Pos;

#[derive(Default)]
pub struct LexResult {
    pub matched: Pos,
    pub group: Option<Pos>,
}
