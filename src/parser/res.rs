#[derive(Debug, PartialEq, Eq, Clone, Copy)]
pub enum PRes {
    Ok,
    Err,
    Break(usize),
}
