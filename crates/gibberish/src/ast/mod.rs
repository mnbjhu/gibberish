use gibberish_core::node::Group;
use gibberish_gibberish_parser::{Gibberish, GibberishSyntax};

use crate::{
    ast::{builder::ParserBuilder, stmt::StmtAst},
    parser::Parser,
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

    pub fn build_parser(self, builder: &mut ParserBuilder) {
        self.iter().for_each(|it| match it {
            StmtAst::Parser(p) => {
                builder.vars.push((p.name().text.clone(), Parser::Empty));
            }
            StmtAst::Fold(f) => {
                builder.vars.push((f.name().text.clone(), Parser::Empty));
            }
            _ => {}
        });
        self.iter().for_each(|it| match it {
            StmtAst::Parser(p) => p.build(builder),
            StmtAst::Fold(f) => f.build(builder),
            StmtAst::Token(t) => t.build(builder),
            StmtAst::Keyword(k) => k.build(builder),
        });
        for i in 0..builder.vars.len() {
            let res = builder.vars[i].1.clone().remove_conflicts(builder, 0);
            if res != builder.vars[i].1 {
                println!("Generated parser: {res}")
            }
            builder.vars[i].1 = res;
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
