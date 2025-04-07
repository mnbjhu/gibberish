use crate::parser::lang::Lang;

pub struct NoSkip<L: Lang> {
    pub token: L::Token,
}
