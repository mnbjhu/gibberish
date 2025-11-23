use std::ops::Range;

use thiserror::Error;

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

#[derive(Debug)]
pub enum OptionAst<'a> {
    Range(Range<u8>),
    Char(u8),
    Regex(RegexAst<'a>),
}

#[derive(Debug, Error)]
pub enum RegexParseErr {}

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

pub fn parse_exact<'a>(regex: &'a str, offset: &mut usize) -> Option<RegexAst<'a>> {
    let start = *offset;
    loop {
        match regex.chars().nth(*offset) {
            Some('|') | Some('[') | Some(']') | Some('(') | Some(')') | Some('\\') | None => break,
            _ => *offset += 1,
        }
    }
    if start == *offset {
        None
    } else {
        Some(RegexAst::Exact(&regex[start..*offset]))
    }
}

pub fn parse_seq<'a>(regex: &'a str, offset: &mut usize) -> Option<RegexAst<'a>> {
    let mut res = vec![];
    loop {
        if matches!(regex.chars().nth(*offset), None | Some('|') | Some(')')) {
            return Some(RegexAst::Seq(res));
        }
        let mut item = parse_regex(regex, offset)?;
        if let Some('*') = regex.chars().nth(*offset) {
            *offset += 1;
            item = RegexAst::Rep0(Box::new(item));
        }
        if let Some('+') = regex.chars().nth(*offset) {
            *offset += 1;
            item = RegexAst::Rep1(Box::new(item));
        }
        res.push(item);
    }
}

fn parse_choice<'a>(regex: &'a str, offset: &mut usize) -> Option<RegexAst<'a>> {
    let Some('[') = regex.chars().nth(*offset) else {
        return None;
    };
    *offset += 1;

    let negate = if let Some('^') = regex.chars().nth(*offset) {
        *offset += 1;
        true
    } else {
        false
    };

    let mut options = vec![];

    while let Some(current) = regex.chars().nth(*offset) {
        if current == ']' {
            *offset += 1;
            return Some(RegexAst::Choice { negate, options });
        };
        options.push(parse_option(regex, offset)?);
    }
    None
}

fn parse_option<'a>(regex: &'a str, offset: &mut usize) -> Option<OptionAst<'a>> {
    if let Some(special) = parse_special(regex, offset) {
        return Some(OptionAst::Regex(special));
    }
    match regex.chars().nth(*offset) {
        Some(char) => {
            *offset += 1;
            if let Some('-') = regex.chars().nth(*offset) {
                *offset += 1;
                let end = regex.chars().nth(*offset)?;
                *offset += 1;
                return Some(OptionAst::Range(char as u8..end as u8));
            } else {
                Some(OptionAst::Char(char as u8))
            }
        }
        _ => None,
    }
}

fn parse_capture<'a>(regex: &'a str, offset: &mut usize) -> bool {
    if !matches!(regex.chars().nth(*offset), Some('?')) {
        return true;
    }
    if !matches!(regex.chars().nth(*offset + 1), Some(':')) {
        return true;
    }
    *offset += 2;
    false
}

fn parse_group<'a>(regex: &'a str, offset: &mut usize) -> Option<RegexAst<'a>> {
    if !matches!(regex.chars().nth(*offset), Some('(')) {
        return None;
    }
    *offset += 1;
    let capture = parse_capture(regex, offset);
    let mut options = vec![];
    loop {
        options.push(parse_seq(regex, offset)?);
        let current = regex.chars().nth(*offset)?;
        if current == ')' {
            *offset += 1;
            break;
        }
        if current == '|' {
            *offset += 1;
            continue;
        } else {
            return None;
        }
    }
    assert_ne!(options.len(), 0);
    Some(RegexAst::Group { options, capture })
}
