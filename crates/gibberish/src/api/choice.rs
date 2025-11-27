use gibberish_core::{err::Expected, lang::CompiledLang};

use crate::api::ptr::{ParserCache, ParserIndex};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Choice {
    pub options: Vec<ParserIndex>,
}

impl Choice {
    pub fn expected(&self, cache: &ParserCache) -> Vec<Expected<CompiledLang>> {
        self.options
            .iter()
            .flat_map(|it| it.get_ref(cache).expected(cache))
            .collect()
    }
    pub fn build_parse(&self, id: usize, f: &mut impl std::fmt::Write) {
        write!(
            f,
            "
function w $parse_{id}(l %state_ptr, w %recover) {{",
        )
        .unwrap();
        for (index, option) in self.options.iter().enumerate() {
            let next = if index + 1 == self.options.len() {
                "@ret"
            } else {
                &format!("@check_{}", index + 1)
            };
            write!(
                f,
                "
@check_{index}
    %res =l call $parse_{option_index}(l %state_ptr, w %recover)
    jnz %res, {next}, @ret",
                option_index = option.index
            )
            .unwrap();
        }
        write!(
            f,
            "
@ret
    ret %res
}}"
        )
        .unwrap();
    }

    pub fn build_peak(&self, id: usize, f: &mut impl std::fmt::Write) {
        write!(
            f,
            "
function w $peak_{id}(l %state_ptr, l %offset, w %recover) {{",
        )
        .unwrap();
        for (index, option) in self.options.iter().enumerate() {
            let next = if index + 1 == self.options.len() {
                "@ret"
            } else {
                &format!("@check_{}", index + 1)
            };
            write!(
                f,
                "
@check_{index}
    %res =l call $peak_{option_index}(l %state_ptr, l %offset, w %recover)
    jnz %res, {next}, @ret",
                option_index = option.index
            )
            .unwrap();
        }
        write!(
            f,
            "
@ret
    ret %res
}}"
        )
        .unwrap();
    }
}

pub fn choice(options: Vec<ParserIndex>, cache: &mut ParserCache) -> ParserIndex {
    Parser::Choice(Choice { options }).cache(cache)
}
