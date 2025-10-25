#[derive(Debug, PartialEq, Eq, Clone, Copy)]
pub enum PRes {
    Ok,
    Err,
    Break(usize),
    Eof,
}

impl PRes {
    #[must_use]
    pub fn is_ok(&self) -> bool {
        matches!(self, PRes::Ok)
    }

    #[must_use]
    pub fn is_err(&self) -> bool {
        !matches!(self, PRes::Ok)
    }
}
