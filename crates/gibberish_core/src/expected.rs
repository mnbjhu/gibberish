use crate::{err::Expected, lang::CompiledLang};

#[repr(C)]
#[derive(Clone, Copy)]
pub struct ExpectedData {
    kind: u32,
    id: u32,
}

impl From<ExpectedData> for Expected<CompiledLang> {
    fn from(value: ExpectedData) -> Self {
        match value.kind {
            0 => Expected::Token(value.id),
            1 => Expected::Group(value.id),
            2 => Expected::Label(value.id),
            kind => panic!("Unsupported kind for expected {kind}"),
        }
    }
}
