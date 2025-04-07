use crate::parser::lang::Lang;

use super::Parser;

pub struct Sep<L: Lang> {
    pub sep: Box<Parser<L>>,
    pub item: Box<Parser<L>>,
}
