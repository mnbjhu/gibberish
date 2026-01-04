#[derive(Default)]
pub struct LexResult {
    pub matched: usize,
    pub group: Option<usize>,
}
