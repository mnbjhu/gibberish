#[repr(C)]
pub struct SliceData {
    ptr: *const u8,
    len: usize,
}

#[unsafe(no_mangle)]
pub extern "C" fn host_print(x: i64) {
    println!("host_print: {x}");
}

#[repr(C)]
#[derive(Debug, Clone, Copy)]
pub struct RawVec<T> {
    pub ptr: *mut T,
    pub len: usize,
    pub cap: usize,
}

impl<'a, T> IntoIterator for &'a RawVec<T> {
    type Item = &'a T;

    type IntoIter = RawVecIter<'a, T>;

    fn into_iter(self) -> Self::IntoIter {
        RawVecIter {
            raw: self,
            index: 0,
        }
    }
}

pub struct RawVecIter<'a, T> {
    raw: &'a RawVec<T>,
    index: usize,
}

impl<'a, T> Iterator for RawVecIter<'a, T> {
    type Item = &'a T;

    fn next(&mut self) -> Option<Self::Item> {
        if self.index == self.raw.len {
            None
        } else {
            unsafe {
                let new = self.raw.ptr.add(self.index);
                self.index += 1;
                Some(&*new)
            }
        }
    }
}

#[repr(C)]
#[derive(Debug)]
pub struct IntVec {
    pub ptr: *mut u64,
    pub len: usize,
    pub cap: usize,
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
        if value.cap == 0 {
            Vec::new()
        } else {
            unsafe { Vec::from_raw_parts(value.ptr, value.len, value.cap) }
        }
    }
}

impl From<IntVec> for Vec<u64> {
    fn from(value: IntVec) -> Self {
        if value.cap == 0 {
            Vec::new()
        } else {
            unsafe { Vec::from_raw_parts(value.ptr, value.len, value.cap) }
        }
    }
}
