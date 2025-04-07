use crate::parser::lang::Lang;

pub struct Skip<L: Lang> {
    pub token: L::Token,
}
