use crate::lexer::{
    choice::parse_choice, exact::parse_exact, group::parse_group, option::OptionAst,
};

pub mod build;
pub mod choice;
pub mod exact;
pub mod group;
pub mod option;
pub mod seq;

#[derive(Debug)]
pub enum RegexAst {
    Exact(String),
    Seq(Vec<RegexAst>),
    Choice {
        negate: bool,
        options: Vec<OptionAst>,
    },
    Group {
        options: Vec<RegexAst>,
        capture: bool,
    },
    Rep0(Box<RegexAst>),
    Rep1(Box<RegexAst>),
    Whitepace,
    Any,
    Error,
}

pub fn parse_regex<'a>(regex: &'a str, offset: &mut usize) -> Option<RegexAst> {
    if let Some(special) = parse_special(regex, offset) {
        return Some(special);
    }
    if let Some(choice) = parse_choice(regex, offset) {
        return Some(choice);
    }
    if let Some(group) = parse_group(regex, offset) {
        return Some(group);
    }
    if let Some(exact) = parse_exact(regex, offset) {
        return Some(exact);
    }
    None
}

pub fn parse_special<'a>(regex: &'a str, offset: &mut usize) -> Option<RegexAst> {
    let current = regex.chars().nth(*offset);
    if let Some('.') = current {
        *offset += 1;
        return Some(RegexAst::Any);
    };
    if let Some('\\') = current {
        let next = regex.chars().nth(*offset + 1)?;
        let res = match next {
            'n' => Some(RegexAst::Exact("\n".to_string())),
            't' => Some(RegexAst::Exact("\t".to_string())),
            '"' => Some(RegexAst::Exact("\"".to_string())),
            's' => Some(RegexAst::Whitepace),
            '\\' => Some(RegexAst::Exact("\\".to_string())),
            '[' => Some(RegexAst::Exact("[".to_string())),
            ']' => Some(RegexAst::Exact("]".to_string())),
            '(' => Some(RegexAst::Exact("(".to_string())),
            ')' => Some(RegexAst::Exact(")".to_string())),
            '{' => Some(RegexAst::Exact("{".to_string())),
            '}' => Some(RegexAst::Exact("}".to_string())),
            '+' => Some(RegexAst::Exact("+".to_string())),
            '*' => Some(RegexAst::Exact("*".to_string())),
            '|' => Some(RegexAst::Exact("|".to_string())),
            '.' => Some(RegexAst::Exact(".".to_string())),
            _ => None,
        };
        if res.is_some() {
            *offset += 2;
        }
        res
    } else {
        None
    }
}
