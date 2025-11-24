use crate::RawVec;

#[repr(C)]
#[derive(Debug)]
pub struct Lexeme {
    pub kind: u64,
    pub start: u64,
    pub end: u64,
}

unsafe extern "C" {
    pub fn lex(ptr: *const u8, len: usize) -> RawVec<Lexeme>;
}

fn do_lex(text: &str) -> Vec<Lexeme> {
    unsafe { lex(text.as_ptr(), text.len()).into() }
}
