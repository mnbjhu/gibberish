use gibberish_tree::{
    node::{LexemeData, NodeData},
    vec::{IntVec, RawVec},
};

extern "C" fn push_long(ptr: *mut Vec<usize>, value: usize) -> u32 {
    unsafe {
        ptr.as_mut().unwrap().push(value);
    }
    1
}

extern "C" fn new_long_array() -> IntVec {
    let mut vec = Vec::<u64>::new();
    IntVec {
        ptr: vec.as_mut_ptr(),
        len: vec.len(),
        cap: vec.capacity(),
    }
}

extern "C" fn push_tok(ptr: *mut Vec<LexemeData>, value: *const LexemeData) -> u32 {
    unsafe {
        let data = value.as_ref().unwrap().clone();
        ptr.as_mut().unwrap().push(data);
    }
    1
}

extern "C" fn new_tok_array() -> RawVec<LexemeData> {
    let mut vec = Vec::<LexemeData>::new();
    RawVec {
        ptr: vec.as_mut_ptr(),
        len: vec.len(),
        cap: vec.capacity(),
    }
}

extern "C" fn push_node(ptr: *mut Vec<NodeData>, value: *const NodeData) -> u32 {
    unsafe {
        let data = value.as_ref().unwrap().clone();
        ptr.as_mut().unwrap().push(data);
    }
    1
}

extern "C" fn new_node_array() -> RawVec<NodeData> {
    let mut vec = Vec::<NodeData>::new();
    RawVec {
        ptr: vec.as_mut_ptr(),
        len: vec.len(),
        cap: vec.capacity(),
    }
}

extern "C" fn disolve_group(ptr: *mut Vec<NodeData>) -> u32 {
    unsafe {
        let vec = ptr.as_mut().unwrap();
        let outer = vec.pop().unwrap();
        let last = vec.last_mut().unwrap();
    }
    1
}
