use crate::{
    lexer::{RegexAst, option::OptionAst},
    runtime::lexer::{pos::Pos, res::LexResult, state::LexerState},
};

impl RegexAst {
    pub fn lex(&self, mut pos: Pos, state: &mut LexerState) -> Option<LexResult> {
        match self {
            RegexAst::Exact(t) => {
                if let Some(matched) = state.cmp_str(pos.offset, t) {
                    Some(LexResult {
                        matched,
                        group: None,
                    })
                } else {
                    None
                }
            }
            RegexAst::Seq(regex_asts) => {
                let mut res = LexResult::default();
                for part in regex_asts {
                    let p = part.lex(pos, state)?;
                    pos += p.matched;
                    res.matched += p.matched;
                    if let Some(group) = p.group {
                        res.group = Some(group)
                    }
                }
                Some(res)
            }
            RegexAst::Choice { negate, options } => {
                if *negate {
                    for op in options {
                        if op.lex(pos, state).is_some() {
                            return None;
                        }
                    }
                    let (Some(_), matched) = state.get_char_with_pos(pos.offset) else {
                        return None;
                    };
                    Some(LexResult {
                        matched,
                        group: None,
                    })
                } else {
                    for op in options {
                        if let Some(res) = op.lex(pos, state) {
                            return Some(res);
                        }
                    }
                    None
                }
            }
            RegexAst::Group { options, capture } => {
                let mut res = None;
                for op in options {
                    res = op.lex(pos, state);
                    if res.is_some() {
                        break;
                    }
                }
                if *capture && let Some(res) = res {
                    Some(LexResult {
                        matched: res.matched,
                        group: Some(res.matched),
                    })
                } else {
                    res
                }
            }
            RegexAst::Rep0(regex_ast) => {
                let mut matched = Pos::zero();
                while let Some(res) = regex_ast.lex(pos, state)
                    && res.matched.offset > 0
                {
                    matched += res.matched;
                    pos += res.matched;
                }
                Some(LexResult {
                    matched,
                    group: None,
                })
            }
            RegexAst::Rep1(regex_ast) => {
                let mut matched = Pos::zero();
                if let Some(res) = regex_ast.lex(pos, state) {
                    pos += res.matched;
                    matched += res.matched;
                } else {
                    return None;
                }
                while let Some(res) = regex_ast.lex(pos, state)
                    && res.matched.offset > 0
                {
                    pos += res.matched;
                    matched += res.matched;
                }
                Some(LexResult {
                    matched,
                    group: None,
                })
            }
            RegexAst::Whitepace => {
                if let (Some(char), pos) = state.get_char_with_pos(pos.offset)
                    && char.is_whitespace()
                {
                    Some(LexResult {
                        matched: pos,
                        group: None,
                    })
                } else {
                    None
                }
            }
            RegexAst::Any => {
                if let (Some(_), matched) = state.get_char_with_pos(pos.offset) {
                    Some(LexResult {
                        matched,
                        group: None,
                    })
                } else {
                    None
                }
            }
            RegexAst::Error => todo!(),
        }
    }
}

impl OptionAst {
    pub fn lex(&self, pos: Pos, state: &mut LexerState) -> Option<LexResult> {
        match self {
            OptionAst::Range(range) => {
                if let (Some(char), matched) = state.get_char_with_pos(pos.offset) {
                    let it = char as u8;
                    if it >= *range.start() && it <= *range.end() {
                        return Some(LexResult {
                            matched,
                            group: None,
                        });
                    }
                }
                None
            }
            OptionAst::Char(char) => {
                if let (Some(it), matched) = state.get_char_with_pos(pos.offset)
                    && it as u8 == *char
                {
                    Some(LexResult {
                        matched,
                        group: None,
                    })
                } else {
                    None
                }
            }
            OptionAst::Regex(regex_ast) => regex_ast.lex(pos, state),
        }
    }
}
