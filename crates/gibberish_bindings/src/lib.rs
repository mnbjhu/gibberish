// use crate::{
//     node::Node,
//     state::{State, default_state_ptr, get_state, parse as p},
//     vec::RawVec,
// };

// pub mod expected;
// pub mod lex;
// pub mod node;
// pub mod state;
// pub mod vec;
//
// pub fn parse(text: &str) -> Node {
//     unsafe {
//         let state_ptr = default_state_ptr(text.as_ptr(), text.len());
//         p(state_ptr);
//         let state_data = get_state(state_ptr);
//         let mut state: State = state_data.into();
//         assert_eq!(state.stack.len(), 1);
//         state.stack.pop().unwrap()
//     }
// }
