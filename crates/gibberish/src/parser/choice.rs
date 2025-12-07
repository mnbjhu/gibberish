use std::collections::HashSet;

use gibberish_core::{err::Expected, lang::CompiledLang};

use crate::{
    ast::builder::ParserBuilder,
    parser::{
        just::just,
        ptr::{ParserCache, ParserIndex},
        seq::seq,
    },
};

use super::Parser;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub struct Choice {
    pub options: Vec<ParserIndex>,
    pub default: Option<u32>,
}

impl Choice {
    pub fn expected(&self, cache: &ParserCache) -> Vec<Expected<CompiledLang>> {
        self.options
            .iter()
            .flat_map(|it| it.get_ref(cache).expected(cache))
            .collect()
    }

    pub fn build_parse(&self, builder: &ParserBuilder, id: usize, f: &mut impl std::fmt::Write) {
        let ret_err = match self.default {
            Some(u32::MAX) => &format!(
                "\n@ret_err
    call $group_at(l %state_ptr, w {default}, l %unmatched_checkpoint)
    ret %res
",
                default = builder.vars.len() + 1
            ),
            Some(default) => &format!(
                "\n@ret_err
    call $group_at(l %state_ptr, w {default}, l %unmatched_checkpoint)
    ret %res
",
            ),
            None => {
                "\n@ret_err
    ret %res
"
            }
        };
        write!(
            f,
            "
# Build Choice
function w $parse_{id}(l %state_ptr, w %recover, l %unmatched_checkpoint) {{",
        )
        .unwrap();
        for (index, option) in self.options.iter().enumerate() {
            let next = if index + 1 == self.options.len() {
                "@ret_err"
            } else {
                &format!("@check_{}", index + 1)
            };
            write!(
                f,
                "
@check_{index}
    %res =l call $parse_{option_index}(l %state_ptr, w %recover, l %unmatched_checkpoint)
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
{ret_err}
}}"
        )
        .unwrap();
    }

    pub fn start_tokens(&self, cache: &ParserCache) -> HashSet<u32> {
        let mut set = HashSet::new();
        for option in &self.options {
            set.extend(option.get_ref(cache).start_tokens(cache));
        }
        set
    }

    pub fn is_optional(&self, cache: &ParserCache) -> bool {
        false // TODO: Look into whether this is easy to support
    }

    pub fn after_token(&self, token: u32, builder: &mut ParserBuilder) -> Option<ParserIndex> {
        let mut parsers = vec![];
        for (index, p) in self.options.iter().enumerate() {
            if p.get_ref(&builder.cache)
                .start_tokens(&builder.cache)
                .contains(&token)
            {
                parsers.push(index);
            }
        }
        if parsers.is_empty() {
            panic!()
        } else if parsers.len() == 1 {
            return self.options[parsers[0]]
                .get_ref(&builder.cache)
                .clone()
                .after_token(token, builder);
        }
        let require_named = self
            .options
            .iter()
            .all(|it| matches!(it.get_ref(&builder.cache), Parser::Named(_)));
        let mut default = None;
        let rest = parsers
            .iter()
            .filter_map(|index| {
                if let Some(rest) = self.options[*index]
                    .get_ref(&builder.cache)
                    .clone()
                    .after_token(token, builder)
                {
                    Some(rest)
                } else {
                    if require_named {
                        let name = self.options[*index]
                            .get_ref(&builder.cache)
                            .get_name(&builder.cache)
                            .unwrap();
                        if default.is_none() {
                            default = Some(name);
                        } else {
                            panic!("Expected named")
                        }
                    }
                    None
                }
            })
            .collect::<Vec<_>>();
        if default.is_none() {
            default = Some(u32::MAX);
        }
        let option = if rest.is_empty() {
            panic!("Found 0 intersect");
        } else {
            seq(
                vec![
                    just(token, &mut builder.cache),
                    Parser::Choice(Choice {
                        options: rest,
                        default,
                    })
                    .cache(&mut builder.cache)
                    .reduce_conflicts(builder, 0)?,
                ],
                &mut builder.cache,
            )
        };
        Some(option)
    }
}

pub fn choice(options: Vec<ParserIndex>, cache: &mut ParserCache) -> ParserIndex {
    Parser::Choice(Choice {
        options,
        default: None,
    })
    .cache(cache)
}
