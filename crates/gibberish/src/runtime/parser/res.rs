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
}
