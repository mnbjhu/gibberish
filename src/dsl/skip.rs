use crate::parser::lang::Lang;

pub struct Skip<L: Lang> {
    token: L::Token,
}
