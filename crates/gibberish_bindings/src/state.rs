use crate::{
    RawVec,
    lex::Lexeme,
    node::{Node, NodeData},
};

unsafe extern "C" {
    pub fn default_state(ptr: *const u8, len: usize) -> StateData;
    pub fn default_state_ptr(ptr: *const u8, len: usize) -> *const StateData;
    pub fn parse(ptr: *const StateData) -> u32;
    pub fn bump(ptr: *const StateData);
    pub fn bump_err(ptr: *const StateData);
    pub fn bumpN(ptr: *const StateData, n: usize) -> u32;
    pub fn enter_group(ptr: *const StateData, name: u32) -> u32;
    pub fn exit_group(ptr: *const StateData) -> u32;
    pub fn get_state(ptr: *const StateData) -> StateData;
    pub fn kind_at_offset(ptr: *const StateData, offset: usize) -> usize;
}

#[derive(Debug)]
pub struct State {
    pub tokens: Vec<Lexeme>,
    pub stack: Vec<Node>,
    pub offset: usize,
    pub delim_stack: Vec<usize>,
    pub skip: Vec<usize>,
}

#[repr(C)]
#[derive(Debug)]
pub struct StateData {
    tokens: RawVec<Lexeme>,
    stack: RawVec<NodeData>,
    offset: usize,
    delim_stack: RawVec<usize>,
    skip: RawVec<usize>,
}

impl StateData {
    fn bump(&mut self) {
        let ptr: *mut StateData = self;
        unsafe { bump(ptr) };
    }

    fn bump_err(&mut self) {
        let ptr: *mut StateData = self;
        unsafe { bump_err(ptr) };
    }

    fn enter(&mut self, kind: u32) {
        let ptr: *mut StateData = self;
        unsafe { enter_group(ptr, kind) };
    }

    fn exit(&mut self) {
        let ptr: *mut StateData = self;
        unsafe { exit_group(ptr) };
    }

    fn kind_at_offset(&self, offset: usize) -> usize {
        let ptr: *const StateData = self;
        unsafe { kind_at_offset(ptr, offset) }
    }
}

impl From<StateData> for State {
    fn from(value: StateData) -> Self {
        Self {
            tokens: value.tokens.into(),
            stack: Vec::from(value.stack)
                .into_iter()
                .map(|it| it.into())
                .collect(),
            offset: value.offset,
            delim_stack: value.delim_stack.into(),
            skip: value.skip.into(),
        }
    }
}

impl From<&str> for State {
    fn from(value: &str) -> Self {
        StateData::from(value).into()
    }
}

impl From<&str> for StateData {
    fn from(value: &str) -> Self {
        unsafe { default_state(value.as_ptr(), value.len()) }
    }
}

#[cfg(test)]
mod tests {
    use crate::{
        node::Node,
        state::{State, StateData},
    };

    #[test]
    fn test_create_state() {
        let state = State::from("select \"some\" from thing;");
        assert_eq!(state.stack.len(), 1);
        if let Node::Group { children, .. } = &state.stack[0] {
            assert_eq!(children.len(), 0)
        } else {
            panic!("Expected root to be a group")
        }
        assert_eq!(state.tokens.len(), 8);
        assert_eq!(state.offset, 0);
        assert_eq!(state.delim_stack.len(), 0);
        assert_eq!(state.skip.len(), 0);
    }

    #[test]
    fn test_bump() {
        let mut state = StateData::from("select \"some\" from thing;");
        state.bump();
        let state = State::from(state);
        assert_eq!(state.stack.len(), 1);
        if let Node::Group { children, .. } = &state.stack[0] {
            assert_eq!(children.len(), 1)
        } else {
            panic!("Expected root to be a group")
        }
        assert_eq!(state.tokens.len(), 8);
        assert_eq!(state.offset, 1);
    }

    #[test]
    fn test_kind_at_offset() {
        let state = StateData::from("select \"some\" from thing;");
        assert_eq!(state.kind_at_offset(0), 0);
        assert_eq!(state.kind_at_offset(1), 5);
        assert_eq!(state.kind_at_offset(2), 4);
        assert_eq!(state.kind_at_offset(3), 5);
        assert_eq!(state.kind_at_offset(4), 1);
        assert_eq!(state.kind_at_offset(5), 5);
        assert_eq!(state.kind_at_offset(6), 6);
    }
}
