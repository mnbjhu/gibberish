use crate::{
    lexer::{RegexAst, option::OptionAst},
    runtime::lexer::{res::LexResult, state::LexerState},
};

impl RegexAst {
    pub fn lex(&self, mut offset: usize, state: &mut LexerState) -> Option<LexResult> {
        match self {
            RegexAst::Exact(t) => {
                if state.cmp_str(offset, t) {
                    Some(LexResult {
                        matched: t.len(),
                        group: None,
                    })
                } else {
                    None
                }
            }
            RegexAst::Seq(regex_asts) => {
                let mut res = LexResult::default();
                for part in regex_asts {
                    let p = part.lex(offset, state)?;
                    offset += p.matched;
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
                        if op.lex(offset, state).is_some() {
                            return None;
                        }
                    }
                    let matched = if state.get_char(offset).is_some() {
                        1
                    } else {
                        0
                    };
                    Some(LexResult {
                        matched,
                        group: None,
                    })
                } else {
                    for op in options {
                        if let Some(res) = op.lex(offset, state) {
                            return Some(res);
                        }
                    }
                    None
                }
            }
            RegexAst::Group { options, capture } => {
                let mut res = None;
                for op in options {
                    res = op.lex(offset, state);
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
                let mut matched = 0;
                while let Some(res) = regex_ast.lex(offset, state)
                    && res.matched > 0
                {
                    matched += res.matched;
                    offset += res.matched;
                }
                Some(LexResult {
                    matched,
                    group: None,
                })
            }
            RegexAst::Rep1(regex_ast) => {
                let mut matched = 0;
                if let Some(res) = regex_ast.lex(offset, state) {
                    offset += res.matched;
                    matched += res.matched;
                } else {
                    return None;
                }
                while let Some(res) = regex_ast.lex(offset, state)
                    && res.matched > 0
                {
                    offset += res.matched;
                    matched += res.matched;
                }
                Some(LexResult {
                    matched,
                    group: None,
                })
            }
            RegexAst::Whitepace => {
                if let Some(char) = state.get_char(offset)
                    && char.is_whitespace()
                {
                    Some(LexResult {
                        matched: 1,
                        group: None,
                    })
                } else {
                    None
                }
            }
            RegexAst::Any => {
                if state.get_char(offset).is_some() {
                    Some(LexResult {
                        matched: 1,
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
    pub fn lex(&self, offset: usize, state: &mut LexerState) -> Option<LexResult> {
        match self {
            OptionAst::Range(range) => {
                if state.get_char(offset).is_some_and(|it| {
                    let it = it as u8;
                    it >= *range.start() && it <= *range.end()
                }) {
                    Some(LexResult {
                        matched: 1,
                        group: None,
                    })
                } else {
                    None
                }
            }
            OptionAst::Char(char) => {
                if state.get_char(offset).is_some_and(|it| it as u8 == *char) {
                    Some(LexResult {
                        matched: 1,
                        group: None,
                    })
                } else {
                    None
                }
            }
            OptionAst::Regex(regex_ast) => regex_ast.lex(offset, state),
        }
    }
}
