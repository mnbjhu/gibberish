use std::{collections::HashMap, fmt::Display};

use gibberish_core::{lang::Lang, node::Node};

#[derive(Clone, Copy, Hash, PartialEq, Eq, Debug)]
pub struct RTLang;
impl Display for RTLang {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "RTLang")
    }
}

pub type BreakIndex = usize;
pub type StageIndex = usize;

impl Lang for RTLang {
    type Token = u32;

    type Syntax = u32;

    type Label = u32;
}

pub struct PState {
    pub tokens: Vec<u32>,
    pub offset: usize,
    pub node_stack: Vec<Node<RTLang>>,
    pub skip: Vec<u32>,
    pub break_stack: Vec<Vec<u32>>,
    pub checkpoints: Vec<usize>,
    pub break_stack_starts: Vec<usize>,
}

pub struct Stage {
    pub actions: Vec<StageAction>,
    pub map: HashMap<u32, StageIndex>,
    pub break_map: HashMap<BreakIndex, StageIndex>,
    pub default: Option<StageIndex>,
}

pub enum StageAction {
    PushCheckpoint,
    PopCheckpoint,
    FinishCheckpoint(u32),
    PushBreak(Vec<u32>),
    PopBreak,
    PushBreakStart,
    PopBreakStart,
}

pub struct PBuilder {
    pub stages: Vec<Stage>,
}

fn main() {}
