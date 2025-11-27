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
pub enum RegexAst<'a> {
    Exact(&'a str),
    Seq(Vec<RegexAst<'a>>),
    Choice {
        negate: bool,
        options: Vec<OptionAst<'a>>,
    },
    Group {
        options: Vec<RegexAst<'a>>,
        capture: bool,
    },
    Rep0(Box<RegexAst<'a>>),
    Rep1(Box<RegexAst<'a>>),
    Whitepace,
    Any,
}

pub fn parse_regex<'a>(regex: &'a str, offset: &mut usize) -> Option<RegexAst<'a>> {
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

pub fn parse_special<'a>(regex: &'a str, offset: &mut usize) -> Option<RegexAst<'a>> {
    let current = regex.chars().nth(*offset);
    if let Some('.') = current {
        *offset += 1;
        return Some(RegexAst::Any);
    };
    if let Some('\\') = current {
        let next = regex.chars().nth(*offset + 1)?;
        let res = match next {
            'n' => Some(RegexAst::Exact("\n")),
            't' => Some(RegexAst::Exact("\t")),
            '"' => Some(RegexAst::Exact("\"")),
            's' => Some(RegexAst::Whitepace),
            '\\' => Some(RegexAst::Exact("\\")),
            '[' => Some(RegexAst::Exact("[")),
            ']' => Some(RegexAst::Exact("]")),
            '(' => Some(RegexAst::Exact("(")),
            ')' => Some(RegexAst::Exact(")")),
            '{' => Some(RegexAst::Exact("{")),
            '}' => Some(RegexAst::Exact("}")),
            '+' => Some(RegexAst::Exact("+")),
            '*' => Some(RegexAst::Exact("*")),
            '|' => Some(RegexAst::Exact("|")),
            '.' => Some(RegexAst::Exact(".")),
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
