use std::{
    collections::HashSet,
    fmt::{Display, Write},
};

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
    parser::{
        checkpoint::Checkpoint, fold_once::FoldOnce, rename::Rename, repeated::Repeated,
        unskip::UnSkip,
    },
};

pub mod build;
pub mod checkpoint;
pub mod choice;
pub mod delim;
pub mod fold_once;
pub mod just;
pub mod named;
pub mod optional;
pub mod rename;
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
    Rename(Rename),
    Checkpoint(Checkpoint),
    Empty,
    Reference(String),
}

impl Display for Parser {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Parser::Just(just) => write!(f, "{just}"),
            Parser::Choice(choice) => write!(f, "{choice}"),
            Parser::Seq(seq) => write!(f, "{seq}"),
            Parser::Sep(sep) => write!(f, "{sep}"),
            Parser::Delim(_) => todo!(),
            Parser::Named(named) => write!(f, "{named}"),
            Parser::Skip(skip) => write!(f, "{skip}"),
            Parser::UnSkip(un_skip) => write!(f, "{un_skip}"),
            Parser::Optional(optional) => write!(f, "{optional}"),
            Parser::FoldOnce(fold_once) => write!(f, "{fold_once}"),
            Parser::Repeated(repeated) => write!(f, "{repeated}"),
            Parser::Rename(rename) => write!(f, "{rename}"),
            Parser::Checkpoint(checkpoint) => write!(f, "{checkpoint}"),
            Parser::Empty => todo!(),
            Parser::Reference(n) => write!(f, "{n}"),
        }
    }
}

impl Parser {
    pub fn build(&self, builder: &mut ParserBuilder, f: &mut impl Write) -> usize {
        if let Some(existing) = builder.built.get(self) {
            *existing
        } else {
            let id = builder.built.len();
            builder.built.insert(self.clone(), id);
            self.build_parse(id, builder, f);
            self.build_peak(id, builder, f);
            self.build_expected(id, builder, f);
            id
        }
    }

    pub fn get_id(&self, builder: &mut ParserBuilder) -> usize {
        *builder
            .built
            .get(self)
            .expect("Parser has not been built yet")
    }
    pub fn expected(&self, builder: &ParserBuilder) -> Vec<Expected<CompiledLang>> {
        debug!("Getting expected for {}", self.name());
        match self {
            Parser::Just(just) => just.expected(builder),
            Parser::Choice(choice) => choice.expected(builder),
            Parser::Seq(seq) => seq.expected(builder),
            Parser::Sep(sep) => sep.expected(builder),
            Parser::Delim(delim) => delim.expected(builder),
            Parser::Named(named) => named.expected(builder),
            Parser::Skip(skip) => skip.expected(builder),
            Parser::Optional(optional) => optional.expected(builder),
            Parser::UnSkip(un_skip) => un_skip.expected(builder),
            Parser::FoldOnce(fold_once) => fold_once.expected(builder),
            Parser::Empty => todo!(),
            Parser::Repeated(repeated) => repeated.expected(builder),
            Parser::Rename(rename) => rename.expected(builder),
            Parser::Checkpoint(checkpoint) => checkpoint.expected(builder),
            Parser::Reference(n) => builder.get_var(n).unwrap().expected(builder),
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
            Parser::Rename(_) => "Rename".to_string(),
            Parser::Checkpoint(_) => "Checkpoint".to_string(),
            Parser::Reference(n) => format!("Reference({n})"),
        }
    }

    pub fn build_parse(&self, id: usize, builder: &mut ParserBuilder, f: &mut impl Write) {
        match self {
            Parser::Just(just) => just.build_parse(id, builder, f),
            Parser::Choice(choice) => choice.build_parse(id, builder, f),
            Parser::Seq(seq) => seq.build_parse(id, builder, f),
            Parser::Sep(sep) => sep.build_parse(id, builder, f),
            Parser::Delim(delim) => delim.build_parse(id, builder, f),
            Parser::Named(named) => named.build_parse(id, builder, f),
            Parser::Skip(skip) => skip.build_parse(id, builder, f),
            Parser::UnSkip(unskip) => unskip.build_parse(id, builder, f),
            Parser::Optional(optional) => optional.build_parse(id, builder, f),
            Parser::FoldOnce(fold_once) => fold_once.build_parse(id, builder, f),
            Parser::Repeated(repeated) => repeated.build_parse(id, builder, f),
            Parser::Empty => todo!(),
            Parser::Rename(rename) => rename.build_parse(id, builder, f),
            Parser::Checkpoint(checkpoint) => checkpoint.build_parse(id, builder, f),
            Parser::Reference(n) => builder.get_var(n).unwrap().build_parse(id, builder, f),
        }
    }

    pub fn build_peak(&self, id: usize, builder: &ParserBuilder, f: &mut impl Write) {
        let options = self.start_tokens(builder);

        write!(
            f,
            "
function w $peak_{id}(l %state_ptr, l %offset, w %recover) {{
@start
    %current =l call $current_kind(l %state_ptr)
    jmp @check_0
",
        )
        .unwrap();
        for (index, option) in options.iter().enumerate() {
            let next = if index + 1 == options.len() {
                "@ret_err"
            } else {
                &format!("@check_{}", index + 1)
            };
            write!(
                f,
                "
@check_{index}
    %res =l ceql %current, {option}
    jnz %res, @ret_ok, {next}",
                option = builder.get_token_id(option)
            )
            .unwrap();
        }
        write!(
            f,
            "
@ret_ok
    ret 0
@ret_err
    ret 1
}}",
        )
        .unwrap();
    }

    pub fn build_expected(&self, id: usize, builder: &ParserBuilder, f: &mut impl Write) {
        if self.is_optional(builder) {
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

        let expected = self.expected(builder);
        write!(f, "\ndata $expected_{id}_data = {{").unwrap();
        expected.iter().enumerate().for_each(|(index, it)| {
            if index != 0 {
                write!(f, ",").unwrap();
            }
            let (kind, id) = match it {
                Expected::Token(id) => (0, id),
                Expected::Group(id) => (1, id),
                Expected::Label(id) => (2, id),
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

    pub fn start_tokens(&self, builder: &ParserBuilder) -> HashSet<String> {
        match self {
            Parser::Just(just) => just.start_tokens(builder),
            Parser::Choice(choice) => choice.start_tokens(builder),
            Parser::Seq(seq) => seq.start_tokens(builder),
            Parser::Sep(sep) => sep.start_tokens(builder),
            Parser::Delim(delim) => delim.start_tokens(builder),
            Parser::Named(named) => named.start_tokens(builder),
            Parser::Skip(skip) => skip.start_tokens(builder),
            Parser::UnSkip(un_skip) => un_skip.start_tokens(builder),
            Parser::Optional(optional) => optional.start_tokens(builder),
            Parser::FoldOnce(fold_once) => fold_once.start_tokens(builder),
            Parser::Repeated(repeated) => repeated.start_tokens(builder),
            Parser::Empty => todo!(),
            Parser::Rename(rename) => rename.start_tokens(builder),
            Parser::Checkpoint(checkpoint) => checkpoint.start_tokens(builder),
            Parser::Reference(n) => builder.get_var(n).unwrap().start_tokens(builder),
        }
    }

    pub fn is_optional(&self, builder: &ParserBuilder) -> bool {
        match self {
            Parser::Just(just) => just.is_optional(),
            Parser::Choice(choice) => choice.is_optional(builder),
            Parser::Seq(seq) => seq.is_optional(builder),
            Parser::Sep(sep) => sep.is_optional(builder),
            Parser::Delim(delim) => delim.is_optional(builder),
            Parser::Named(named) => named.is_optional(builder),
            Parser::Skip(skip) => skip.is_optional(builder),
            Parser::UnSkip(un_skip) => un_skip.is_optional(builder),
            Parser::Optional(_) => true,
            Parser::FoldOnce(fold_once) => fold_once.is_optional(builder),
            Parser::Repeated(repeated) => repeated.is_optional(builder),
            Parser::Empty => todo!(),
            Parser::Rename(rename) => rename.is_optional(builder),
            Parser::Checkpoint(checkpoint) => checkpoint.is_optional(builder),
            Parser::Reference(n) => builder.get_var(n).unwrap().is_optional(builder),
        }
    }

    pub fn after_token(
        &self,
        token: &str,
        builder: &ParserBuilder,
    ) -> (Option<Parser>, Option<String>) {
        let res = match self {
            Parser::Just(just) => {
                assert_eq!(just.0, token);
                (None, None)
            }
            Parser::Choice(choice) => choice.after_token(token, builder),
            Parser::Seq(seq) => seq.after_token(token, builder),
            Parser::Sep(sep) => todo!(),
            Parser::Delim(delim) => todo!(),
            Parser::Named(named) => named.after_token(token, builder),
            Parser::Skip(skip) => todo!(),
            Parser::UnSkip(un_skip) => todo!(),
            Parser::Optional(optional) => optional.after_token(token, builder),
            Parser::FoldOnce(fold_once) => fold_once.after_token(token, builder),
            Parser::Repeated(repeated) => repeated.after_token(token, builder),
            Parser::Rename(rename) => rename.after_token(token, builder),
            Parser::Empty => todo!(),
            Parser::Checkpoint(checkpoint) => panic!(
                "Tried to get after tokens for 'Checkpoint'. Didn't expect this to be needed??"
            ),
            Parser::Reference(n) => builder.get_var(n).unwrap().after_token(token, builder),
        };
        res
    }

    pub fn get_name(&self, builder: &ParserBuilder) -> Option<String> {
        match self {
            Parser::Just(just) => None,
            Parser::Choice(choice) => None,
            Parser::Seq(seq) => None,
            Parser::Sep(sep) => None,
            Parser::Delim(delim) => todo!(),
            Parser::Named(named) => Some(named.name.clone()),
            Parser::Skip(skip) => skip.inner.get_name(builder),
            Parser::UnSkip(un_skip) => un_skip.inner.get_name(builder),
            Parser::Optional(optional) => todo!(),
            Parser::FoldOnce(fold_once) => Some(fold_once.name.clone()),
            Parser::Repeated(repeated) => None,
            Parser::Rename(rename) => Some(rename.name.clone()),
            Parser::Checkpoint(checkpoint) => None,
            Parser::Empty => todo!(),
            Parser::Reference(n) => builder.get_var(n).unwrap().get_name(builder),
        }
    }

    pub fn remove_conflicts(&self, builder: &ParserBuilder, depth: usize) -> Parser {
        match self {
            Parser::Just(just) => self.clone(),
            Parser::Choice(choice) => choice.remove_conflicts(builder, depth),
            Parser::Seq(seq) => seq.remove_conflicts(builder, depth),
            Parser::Sep(sep) => sep.remove_conflicts(builder, depth),
            Parser::Delim(delim) => todo!(),
            Parser::Named(named) => named.remove_conflicts(builder, depth),
            Parser::Skip(skip) => skip.remove_conflicts(builder, depth),
            Parser::UnSkip(un_skip) => un_skip.remove_conflicts(builder, depth),
            Parser::Optional(optional) => optional.remove_conflicts(builder, depth),
            Parser::FoldOnce(fold_once) => fold_once.remove_conflicts(builder, depth),
            Parser::Repeated(repeated) => repeated.remove_conflicts(builder, depth),
            Parser::Rename(rename) => rename.remove_conflicts(builder, depth),
            Parser::Checkpoint(checkpoint) => checkpoint.remove_conflicts(builder, depth),
            Parser::Empty => todo!(),
            Parser::Reference(n) => self.clone(),
        }
    }
}

#[cfg(test)]
mod tests {
    use std::io::Write as _;

    use gibberish_core::lang::CompiledLang;
    use tempfile::Builder;

    use crate::cli::{self};

    pub fn build_test_parser(src: &'static str) -> CompiledLang {
        let mut src_file = Builder::new().suffix(".gib").tempfile().unwrap();
        write!(&mut src_file, "{src}").unwrap();
        let src_file_path = src_file.path();
        let lib = Builder::new().suffix(".so").tempfile().unwrap();
        let lib_path = lib.path();
        cli::build::build(src_file_path, Some(lib_path));
        CompiledLang::load(lib_path)
    }

    #[macro_export]
    macro_rules! assert_syntax_kind {
        ($lang:ident, $node:expr, $name:ident) => {{
            assert_eq!($lang.syntax_name(&$node.as_group().kind), stringify!($name));
        }};
    }

    #[macro_export]
    macro_rules! assert_token_kind {
        ($lang:ident, $node:expr, $name:ident) => {{
            if let Node::Lexeme(l) = $node {
                assert_eq!($lang.token_name(&l.kind), stringify!($name));
            } else {
                panic!("Expected a lexeme but found {:?}", $node);
            };
        }};
    }
}
