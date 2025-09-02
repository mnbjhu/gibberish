use crate::{
    api::{Parser, just::just, rec::recursive},
    giblang::{lang::GLang, parser::expr::expr_parser},
};

pub fn stmt_parser() -> Parser<GLang> {
    recursive(|stmt| expr_parser(stmt))
}
