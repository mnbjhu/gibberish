use crate::{
    state::{State, default_state_ptr, get_state, parse},
    vec::RawVec,
};

mod expected;
mod lex;
mod node;
mod state;
mod vec;

fn main() {
    unsafe {
        let text = include_str!("../example.gibsql");
        let state_ptr = default_state_ptr(text.as_ptr(), text.len());
        parse(state_ptr);
        let state_data = get_state(state_ptr);
        let state: State = state_data.into();
        assert_eq!(state.stack.len(), 1);
        state.stack.first().unwrap().debug(text);
    }
}
