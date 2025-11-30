use std::{collections::HashSet, fmt::Write};

use choice::Choice;
use delim::Delim;
use gibberish_core::{err::Expected, lang::CompiledLang};
use just::Just;
use named::Named;
use optional::Optional;
use sep::Sep;
use seq::Seq;
use skip::Skip;
use tracing::debug;

use crate::{
    ast::builder::ParserBuilder,
    parser::{fold_once::FoldOnce, ptr::ParserCache, repeated::Repeated, unskip::UnSkip},
};

pub mod build;
pub mod choice;
pub mod delim;
pub mod fold_once;
pub mod just;
pub mod named;
pub mod optional;
pub mod ptr;
pub mod repeated;
pub mod sep;
pub mod seq;
pub mod skip;
pub mod unskip;

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
pub enum Parser {
    Just(Just),
    Choice(Choice),
    Seq(Seq),
    Sep(Sep),
    Delim(Delim),
    Named(Named),
    Skip(Skip),
    UnSkip(UnSkip),
    Optional(Optional),
    FoldOnce(FoldOnce),
    Repeated(Repeated),
    Empty,
}

impl Parser {
    pub fn expected(&self, cache: &ParserCache) -> Vec<Expected<CompiledLang>> {
        debug!("Getting expected for {}", self.name());
        match self {
            Parser::Just(just) => just.expected(),
            Parser::Choice(choice) => choice.expected(cache),
            Parser::Seq(seq) => seq.expected(cache),
            Parser::Sep(sep) => sep.expected(cache),
            Parser::Delim(delim) => delim.expected(cache),
            Parser::Named(named) => named.expected(),
            Parser::Skip(skip) => skip.expected(cache),
            Parser::Optional(optional) => optional.expected(cache),
            Parser::UnSkip(un_skip) => un_skip.expected(cache),
            Parser::FoldOnce(fold_once) => fold_once.expected(cache),
            Parser::Empty => todo!(),
            Parser::Repeated(repeated) => repeated.expected(cache),
        }
    }

    pub fn name(&self) -> String {
        match self {
            Parser::Just(just) => just.to_string(),
            Parser::Choice(_) => "Choice".to_string(),
            Parser::Seq(_) => "Seq".to_string(),
            Parser::Sep(_) => "Sep".to_string(),
            Parser::Delim(_) => "Delim".to_string(),
            Parser::Named(named) => named.to_string(),
            Parser::Skip(_) => "Skip".to_string(),
            Parser::Optional(_) => "Optional".to_string(),
            Parser::UnSkip(_) => "Unskip".to_string(),
            Parser::FoldOnce(_) => "FoldOnce".to_string(),
            Parser::Empty => todo!(),
            Parser::Repeated(_) => "Repeated".to_string(),
        }
    }

    pub fn build_parse(&self, id: usize, f: &mut impl Write) {
        match self {
            Parser::Just(just) => just.build_parse(id, f),
            Parser::Choice(choice) => choice.build_parse(id, f),
            Parser::Seq(seq) => seq.build_parse(id, f),
            Parser::Sep(sep) => sep.build_parse(id, f),
            Parser::Delim(delim) => delim.build_parse(id, f),
            Parser::Named(named) => named.build_parse(id, f),
            Parser::Skip(skip) => skip.build_parse(id, f),
            Parser::UnSkip(_) => todo!(),
            Parser::Optional(optional) => optional.build_parse(id, f),
            Parser::FoldOnce(fold_once) => fold_once.build_parse(id, f),
            Parser::Repeated(repeated) => repeated.build_parse(id, f),
            Parser::Empty => todo!(),
        }
    }

    pub fn build_peak(&self, id: usize, f: &mut impl Write) {
        match self {
            Parser::Just(just) => just.build_peak(id, f),
            Parser::Choice(choice) => choice.build_peak(id, f),
            Parser::Seq(seq) => seq.build_peak(id, f),
            Parser::Sep(sep) => sep.build_peak(id, f),
            Parser::Delim(delim) => delim.build_peak(id, f),
            Parser::Named(named) => named.build_peak(id, f),
            Parser::Skip(skip) => skip.build_peak(id, f),
            Parser::UnSkip(_) => todo!(),
            Parser::Optional(optional) => optional.build_peak(id, f),
            Parser::FoldOnce(fold_once) => fold_once.build_peak(id, f),
            Parser::Repeated(repeated) => repeated.build_peak(id, f),
            Parser::Empty => todo!(),
        }
    }

    pub fn build_expected(&self, id: usize, f: &mut impl Write, builder: &ParserBuilder) {
        if let Parser::Optional(_) = self {
            write!(
                f,
                "
function :vec $expected_{id}() {{
@start
    %res =l alloc8 24
    storel 0, %res
    ret %res
}}
",
            )
            .unwrap();
            return;
        }
        let expected = self.expected(&builder.cache);
        write!(f, "\ndata $expected_{id}_data = {{").unwrap();
        expected.iter().enumerate().for_each(|(index, it)| {
            if index != 0 {
                write!(f, ",").unwrap();
            }
            let (kind, id) = match it {
                Expected::Token(id) => (0, id),
                Expected::Label(id) => (1, id),
                Expected::Group(id) => (2, id),
            };
            write!(f, "l {kind}, l {id}",).unwrap()
        });
        writeln!(f, "}}").unwrap();
        write!(
            f,
            "
function :vec $expected_{id}() {{
@start
    %ptr =l call $malloc(l {size})
    %res =l alloc8 24
    call $memcpy(l %ptr, l $expected_{id}_data, l {size})
    %len_ptr =l add %res, 8
    %cap_ptr =l add %res, 16
    
    storel %ptr, %res
    storel {len}, %len_ptr
    storel {len}, %cap_ptr
    ret %res
}}
",
            size = expected.len() * 16,
            len = expected.len()
        )
        .unwrap();
    }

    pub fn start_tokens(&self, cache: &ParserCache) -> HashSet<u32> {
        match self {
            Parser::Just(just) => just.start_tokens(),
            Parser::Choice(choice) => choice.start_tokens(cache),
            Parser::Seq(seq) => seq.start_tokens(cache),
            Parser::Sep(sep) => sep.start_tokens(cache),
            Parser::Delim(delim) => delim.start_tokens(cache),
            Parser::Named(named) => named.start_tokens(cache),
            Parser::Skip(skip) => skip.start_tokens(cache),
            Parser::UnSkip(un_skip) => todo!(),
            Parser::Optional(optional) => optional.start_tokens(cache),
            Parser::FoldOnce(fold_once) => fold_once.start_tokens(cache),
            Parser::Repeated(repeated) => repeated.start_tokens(cache),
            Parser::Empty => todo!(),
        }
    }

    pub fn is_optional(&self, cache: &ParserCache) -> bool {
        match self {
            Parser::Just(just) => just.is_optional(),
            Parser::Choice(choice) => choice.is_optional(cache),
            Parser::Seq(seq) => seq.is_optional(cache),
            Parser::Sep(sep) => sep.is_optional(cache),
            Parser::Delim(delim) => delim.is_optional(cache),
            Parser::Named(named) => named.is_optional(cache),
            Parser::Skip(skip) => skip.is_optional(cache),
            Parser::UnSkip(un_skip) => todo!(),
            Parser::Optional(optional) => true,
            Parser::FoldOnce(fold_once) => fold_once.is_optional(cache),
            Parser::Repeated(repeated) => repeated.is_optional(cache),
            Parser::Empty => todo!(),
        }
    }
}

#[cfg(test)]
mod tests {
    use std::io::Write as _;

    use gibberish_core::lang::CompiledLang;
    use tempfile::NamedTempFile;

    use crate::cli::{self, build::BuildKind};

    pub fn build_test_parser(src: &'static str) -> CompiledLang {
        let mut src_file = NamedTempFile::new().unwrap();
        write!(&mut src_file, "{src}").unwrap();
        let src_file_path = src_file.path();
        let lib = NamedTempFile::new().unwrap();
        let lib_path = lib.path();
        cli::build::build(src_file_path, Some(lib_path), &BuildKind::Dynamic);
        CompiledLang::load(lib_path)
    }
}
