use gibberish_core::node::Group;
use gibberish_gibberish_parser::{Gibberish, GibberishSyntax};

use crate::{
    ast::{builder::ParserBuilder, stmt::StmtAst},
    parser::{Parser, named::Named},
};

pub mod builder;
pub mod expr;
pub mod stmt;

#[derive(Clone, Copy)]
pub struct RootAst<'a>(pub &'a Group<Gibberish>);

impl<'a> RootAst<'a> {
    pub fn iter(&self) -> impl Iterator<Item = StmtAst<'a>> {
        assert_eq!(self.0.kind, GibberishSyntax::Root);
        self.0.groups().map(StmtAst::from)
    }

    pub fn build_parser(self, builder: &mut ParserBuilder) -> Parser {
        let res = self
            .iter()
            .filter_map(|it| match it {
                StmtAst::Parser(p) => Some(p.build(builder)),
                StmtAst::Fold(f) => Some(f.build(builder)),
                // StmtAst::Highlight(_) => None,
                StmtAst::Token(t) => {
                    t.build(builder);
                    None
                }
                StmtAst::Keyword(k) => {
                    k.build(builder);
                    None
                }
            })
            .last()
            .unwrap();
        match res {
            Parser::Named(Named { inner, .. }) => inner.as_ref().clone(),
            _ => res,
        }
    }
}

pub fn try_parse(id: usize, name: &str, after: &str, f: &mut impl std::fmt::Write) {
    write!(
        f,
        "
@try_parse_{name}
    %res =l call $parse_{id}(l %state_ptr, w %recover, l %unmatched_checkpoint)
    %is_err =l ceql 1, %res
    jnz %is_err, @bump_err_{name}, {after}
@bump_err_{name}
    call $bump_err(l %state_ptr)
    jmp @try_parse_{name}
",
    )
    .unwrap();
}
