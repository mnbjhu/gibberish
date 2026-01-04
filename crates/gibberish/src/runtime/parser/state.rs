use crate::runtime::{lexer::token::Tok, parser::Parser};

pub struct State<'a, 't> {
    pub tokens: &'t [Tok],
    pub break_stack: Vec<&'a Parser>,
    // TODO: We can't use this with fold, we'd need to add any breaks from
    //  unused checkpoints in the named children
    pub checkpoints: Vec<usize>,
}

impl<'a, 't> State<'a, 't> {
    pub fn new(tokens: &'t [Tok]) -> Self {
        Self {
            tokens,
            break_stack: vec![],
            checkpoints: vec![],
        }
    }

    pub fn token_at(&self, offset: usize) -> Option<u32> {
        self.tokens.get(offset).map(|it| it.kind)
    }

    pub fn get_break(&self, offset: usize) -> Option<usize> {
        self.break_stack
            .iter()
            .enumerate()
            .rev()
            .find_map(|(index, it)| {
                if it.peak(offset, self) {
                    Some(index)
                } else {
                    None
                }
            })
    }
}
