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
