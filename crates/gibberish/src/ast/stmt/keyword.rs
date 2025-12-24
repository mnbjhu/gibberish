use gibberish_core::node::{Group, Lexeme};
use gibberish_gibberish_parser::{Gibberish, GibberishToken};
use pretty::{DocAllocator, DocBuilder};

use crate::{
    ast::{LspItem, LspNode, builder::ParserBuilder, expr::ExprAst, stmt::StmtAst},
    lexer::{RegexAst, option::OptionAst},
};

#[derive(Clone, Copy)]
pub struct KeywordDefAst<'a>(pub &'a Group<Gibberish>);

impl<'a> KeywordDefAst<'a> {
    pub fn name(&self) -> Option<&'a Lexeme<Gibberish>> {
        self.0.token_by_kind(GibberishToken::Ident)
    }

    pub fn build(&self, builder: &mut ParserBuilder) {
        builder.lexer.push((
            self.name().unwrap().text.to_string(),
            RegexAst::Seq(vec![
                RegexAst::Group {
                    options: vec![RegexAst::Exact(self.name().unwrap().text.clone())],
                    capture: true,
                },
                RegexAst::Choice {
                    negate: true,
                    options: vec![
                        OptionAst::Range(b'a'..=b'z'),
                        OptionAst::Range(b'A'..=b'Z'),
                        OptionAst::Range(b'0'..=b'9'),
                        OptionAst::Char(b'_'),
                    ],
                },
            ]),
        ));
    }

    pub fn pretty<'b, D, A>(self, allocator: &'b D) -> DocBuilder<'b, D, A>
    where
        D: DocAllocator<'b, A>,
        D::Doc: Clone,
        A: Clone,
        'a: 'b,
    {
        allocator
            .text("keyword ")
            .append(&self.name().unwrap().text)
    }
}

impl<'a> LspItem<'a> for KeywordDefAst<'a> {
    fn at(&self, offset: usize) -> Option<LspNode<'a>> {
        if self.0.span().contains(&offset) {
            if let Some(name) = self.name()
                && name.span.contains(&offset)
            {
                Some(LspNode::Expr(ExprAst::Ident(name)))
            } else {
                Some(LspNode::Stmt(StmtAst::Keyword(*self)))
            }
        } else {
            None
        }
    }
}
