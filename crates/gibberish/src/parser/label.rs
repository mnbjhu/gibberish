use crate::parser::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Label {
    pub name: String,
    pub inner: Box<Parser>,
}

impl Parser {
    pub fn labelled(self, name: String) -> Parser {
        Parser::Label(Label {
            name,
            inner: Box::new(self),
        })
    }
}
