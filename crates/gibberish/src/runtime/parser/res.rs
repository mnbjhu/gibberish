use crate::runtime::parser::node::Node;

#[derive(Debug)]
pub enum Res<'a> {
    Ok(Node<'a>),
    Break(usize),
    Err,
}

impl<'a> Res<'a> {
    pub fn unwrap(self) -> Node<'a> {
        match self {
            Res::Ok(node) => node,
            Res::Break(index) => panic!("Expected Ok node but got Break({index})"),
            Res::Err => panic!("Expected Ok node but got Err"),
        }
    }

    pub fn pop(&mut self) -> Self {
        std::mem::replace(self, Res::Err)
    }

    pub fn map(self, mut f: impl FnMut(Node<'a>) -> Node<'a>) -> Res<'a> {
        match self {
            Res::Ok(node) => Res::Ok(f(node)),
            res => res,
        }
    }

    /// Returns a string description of the result kind for logging
    pub fn kind(&self) -> &'static str {
        match self {
            Res::Ok(_) => "Ok",
            Res::Err => "Err",
            Res::Break(_) => "Break",
        }
    }
}
