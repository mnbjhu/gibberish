use gibberish_core::node::{Group, Lexeme};
use gibberish_gibberish_parser::{Gibberish, GibberishSyntax as S, GibberishToken as T};

use crate::{
    ast::{CheckState, LspItem, LspNode, expr::ExprAst},
    funcs::DEFAULT_FUNCS,
};

#[derive(Clone, Copy)]
pub struct CallAst<'a>(pub &'a Group<Gibberish>);

impl<'a> CallAst<'a> {
    pub fn target(&self) -> ExprAst<'a> {
        self.0.groups().next().unwrap().into()
    }

    pub fn arms(&self) -> impl Iterator<Item = CallArmAst<'a>> {
        self.0.groups().filter_map(|it| {
            if it.kind == S::Call {
                Some(CallArmAst(it))
            } else {
                None
            }
        })
    }
    pub fn check(&self, state: &mut CheckState<'a>) {
        self.target().check(state);
        self.arms().for_each(|it| it.check(state))
    }
}

#[derive(Clone, Copy)]
pub struct CallArmAst<'a>(pub &'a Group<Gibberish>);

impl<'a> CallArmAst<'a> {
    pub fn name(&self) -> Option<&'a Lexeme<Gibberish>> {
        self.0
            .group_by_kind(S::CallName)
            .map(|it| it.token_by_kind(T::Ident).unwrap())
    }

    pub fn args(&self) -> impl Iterator<Item = ExprAst<'a>> {
        let ret: Box<dyn Iterator<Item = ExprAst<'a>>> =
            if let Some(args) = self.0.group_by_kind(S::Args) {
                Box::new(args.groups().map(ExprAst::from))
            } else {
                Box::new(std::iter::empty())
            };
        ret
    }

    pub fn check(&self, state: &mut CheckState<'a>) {
        if let Some(name) = self.name() {
            if let Some(expected) = DEFAULT_FUNCS.iter().find(|it| it.name == name.text) {
                state.func_calls.push(name.span.clone());
                let args_len = self.args().count();
                for (index, arg) in self.args().enumerate() {
                    if index >= expected.args.len() {
                        state.error("This argument is unexpected".to_string(), arg.span());
                    }
                }
                if args_len < expected.args.len() {
                    state.error(
                        format!("Missing arguments: {}", expected.args[args_len..].join(",")),
                        name.span.clone(),
                    );
                }
            } else {
                state.error(
                    format!("Function '{}' not found", name.text),
                    name.span.clone(),
                );
            }
        }

        self.args().for_each(|it| it.check(state));
    }
}

impl<'a> LspItem<'a> for CallArmAst<'a> {
    fn at(&self, offset: usize) -> Option<crate::ast::LspNode<'a>> {
        if self.0.span().contains(&offset) {
            if let Some(name) = self.name()
                && name.span.contains(&offset)
            {
                Some(LspNode::FunctionName(name))
            } else {
                self.args().find_map(|it| it.at(offset))
            }
        } else {
            None
        }
    }
}
