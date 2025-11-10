use crate::lex::Lexeme;

#[repr(C)]
pub struct SliceData {
    ptr: *const u8,
    len: usize,
}

#[repr(C)]
#[derive(Debug)]
pub struct RawVec<T> {
    ptr: *mut T,
    len: usize,
    cap: usize,
}

#[repr(C)]
#[derive(Debug)]
pub struct IntVec {
    ptr: *mut u64,
    len: usize,
    cap: usize,
}

#[link(name = "qbeslice", kind = "static")]
unsafe extern "C" {
    fn test_vec_contains() -> IntVec;
    fn new_vec(size: u32) -> RawVec<Lexeme>;
    fn push(vec: usize, size: usize, item: usize);
    fn pop(vec: usize, size: usize);
    fn push_long(vec: *mut IntVec, item: usize);
}

impl IntVec {
    pub fn new() -> Self {
        unsafe {
            let created = new_vec(8);
            IntVec {
                ptr: created.ptr as *mut u64,
                len: created.len,
                cap: created.cap,
            }
        }
    }

    pub fn push(&mut self, item: usize) {
        let ptr: *mut IntVec = self;
        unsafe {
            push_long(ptr, item);
        }
    }

    pub fn pop(&mut self) {
        let ptr: *mut IntVec = self;
        unsafe {
            pop(ptr as usize, 8);
        }
    }
}

impl From<SliceData> for &str {
    fn from(value: SliceData) -> Self {
        unsafe {
            let bytes = std::slice::from_raw_parts(value.ptr, value.len);
            str::from_utf8_unchecked(bytes)
        }
    }
}

impl<T> From<RawVec<T>> for Vec<T> {
    fn from(value: RawVec<T>) -> Self {
        unsafe { Vec::from_raw_parts(value.ptr, value.len, value.cap) }
    }
}

impl From<IntVec> for Vec<u64> {
    fn from(value: IntVec) -> Self {
        unsafe { Vec::from_raw_parts(value.ptr, value.len, value.cap) }
    }
}

#[cfg(test)]
mod tests {
    use crate::vec::IntVec;

    #[test]
    fn test_create_vec() {
        let raw = IntVec::new();
        let res = Vec::from(raw);
        assert_eq!(res.len(), 0);
        assert_eq!(res.capacity(), 4);
    }

    #[test]
    fn test_push() {
        let mut raw = IntVec::new();
        raw.push(1);
        raw.push(2);
        raw.push(3);
        let res = Vec::from(raw);
        assert_eq!(res, [1, 2, 3]);
        assert_eq!(res.capacity(), 4);
    }

    #[test]
    fn test_overflow() {
        let mut raw = IntVec::new();
        raw.push(1);
        raw.push(2);
        raw.push(3);
        raw.push(4);
        raw.push(5);
        let res = Vec::from(raw);
        assert_eq!(res, [1, 2, 3, 4, 5]);
        assert_eq!(res.capacity(), 16);
    }
}
