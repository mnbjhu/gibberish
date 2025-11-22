use crate::{err::Expected, lang::CompiledLang};

#[repr(C)]
pub struct ExpectedData {
    kind: usize,
    id: usize,
}

impl From<ExpectedData> for Expected<CompiledLang> {
    fn from(value: ExpectedData) -> Self {
        match value.kind {
            0 => Expected::Token(value.id as u32),
            1 => Expected::Group(value.id as u32),
            2 => Expected::Label(value.id as u32),
            kind => panic!("Unsupported kind for expected {kind}"),
        }
    }
}
