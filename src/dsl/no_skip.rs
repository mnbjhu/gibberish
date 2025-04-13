use crate::parser::lang::Lang;

pub struct NoSkip<L: Lang> {
    token: L::Token,
}
