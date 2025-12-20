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
        checkpoint::Checkpoint, fold_once::FoldOnce, label::Label, rename::Rename,
        repeated::Repeated, unskip::UnSkip,
    },
};

pub mod build;
pub mod checkpoint;
pub mod choice;
pub mod delim;
pub mod fold_once;
pub mod just;
pub mod label;
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
    #[allow(unused)]
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
    Label(Label),
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
            Parser::Label(Label { name, inner }) => write!(f, "{inner}:{name}"),
        }
    }
}

impl Parser {
    pub fn build(&self, builder: &mut ParserBuilder, f: &mut impl Write) -> usize {
        let (id, built) = builder.built.get_mut(self).unwrap();
        if *built {
            return *id;
        }
        *built = true;
        let id = *id;
        self.build_parse(id, builder, f);
        self.build_peak(id, builder, f);
        self.build_expected(id, builder, f);
        id
    }

    pub fn get_id(&self, builder: &mut ParserBuilder) -> usize {
        builder
            .built
            .get(self)
            .expect("Parser has not been built yet")
            .0
    }

    pub fn predefine(&self, builder: &mut ParserBuilder, f: &mut impl Write) {
        if builder.built.contains_key(self) {
            return;
        }
        let id = builder.built.len();
        writeln!(
            f,
            "static bool peak_{id}(ParserState *state, size_t offset, bool recover);"
        )
        .unwrap();
        writeln!(
            f,
            "static size_t parse_{id}(ParserState *state, size_t unmatched_checkpoint);"
        )
        .unwrap();

        writeln!(f, "static inline ExpectedVec expected_{id}(void);").unwrap();

        builder
            .built
            .insert(self.clone(), (builder.built.len(), false));
        match self {
            Parser::Just(_) => (),
            Parser::Choice(choice) => {
                choice
                    .options
                    .iter()
                    .for_each(|it| it.predefine(builder, f));
                choice
                    .after_default
                    .iter()
                    .for_each(|it| it.predefine(builder, f));
            }
            Parser::Seq(seq) => seq.0.iter().for_each(|it| it.predefine(builder, f)),
            Parser::Sep(sep) => {
                sep.item.predefine(builder, f);
                sep.sep.predefine(builder, f);
            }
            Parser::Delim(_) => todo!(),
            Parser::Named(named) => named.inner.predefine(builder, f),
            Parser::Skip(skip) => skip.inner.predefine(builder, f),
            Parser::UnSkip(un_skip) => un_skip.inner.predefine(builder, f),
            Parser::Optional(optional) => optional.0.predefine(builder, f),
            Parser::FoldOnce(fold_once) => {
                fold_once.first.predefine(builder, f);
                fold_once.next.predefine(builder, f);
            }
            Parser::Repeated(repeated) => {
                repeated.0.predefine(builder, f);
            }
            Parser::Rename(rename) => rename.inner.predefine(builder, f),
            Parser::Checkpoint(checkpoint) => checkpoint.0.predefine(builder, f),
            Parser::Empty => todo!(),
            Parser::Reference(r) => builder.get_var(r).unwrap().clone().predefine(builder, f),
            Parser::Label(label) => label.inner.predefine(builder, f),
        }
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
            Parser::Label(Label { name, .. }) => {
                let label_id = builder.labels.iter().position(|it| it == name).unwrap();
                vec![Expected::Label(label_id as u32)]
            }
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
            Parser::Label(Label { name, .. }) => format!("Label({name})"),
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
            Parser::Label(label) => label.build_parse(id, builder, f),
        }
    }

    pub fn build_peak(&self, id: usize, builder: &ParserBuilder, f: &mut impl Write) {
        let options = self.start_tokens(builder);

        // Emits:
        //   static bool peak_<id>(ParserState *state, size_t offset, bool recover)
        //
        // Notes:
        // - offset/recover are kept for signature compatibility (like your old QBE),
        //   but this peak implementation only checks the current token kind (same as before).
        // - returns true if the current token kind is in the start set, else false.
        writeln!(
            f,
            r#"
/* peak_{id} */
static bool peak_{id}(ParserState *state, size_t offset, bool recover) {{
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);
"#,
        )
        .unwrap();

        if options.is_empty() {
            // If there are no start tokens, it can never start.
            writeln!(f, "    return false;\n}}\n").unwrap();
            return;
        }

        // Generate a chain of comparisons (keeps output C89/C99-friendly without switch fallthrough tricks)
        for (i, option) in options.iter().enumerate() {
            let tok_id = builder.get_token_id(option);
            if i == 0 {
                writeln!(f, "    if (current == (uint32_t){tok_id}) return true;").unwrap();
            } else {
                writeln!(f, "    if (current == (uint32_t){tok_id}) return true;").unwrap();
            }
        }

        writeln!(f, "    return false;\n}}\n").unwrap();
    }

    pub fn build_expected(&self, id: usize, builder: &ParserBuilder, f: &mut impl Write) {
        // Optional => empty vec, no allocation
        if self.is_optional(builder) {
            writeln!(
                f,
                r#"
/* expected_{id}: optional => empty */
static inline ExpectedVec expected_{id}(void) {{
    return (ExpectedVec){{ .data = NULL, .len = 0, .cap = 0 }};
}}
"#,
            )
            .unwrap();
            return;
        }

        let expected = self.expected(builder);

        // Emit static const Expected table
        writeln!(
            f,
            r#"
/* expected_{id} data */
static const Expected expected_{id}_data[] = {{"#
        )
        .unwrap();

        for it in &expected {
            let (kind, eid) = match it {
                Expected::Token(id) => (0u32, *id),
                Expected::Group(id) => (1u32, *id),
                Expected::Label(id) => (2u32, *id),
            };
            writeln!(f, "    (Expected){{ .kind = {kind}u, .id = {eid}u }},",).unwrap();
        }

        writeln!(f, "}};\n").unwrap();

        // Emit function that heap-copies the table and returns an owning ExpectedVec
        writeln!(
            f,
            r#"
/* expected_{id}: owning ExpectedVec copy */
static inline ExpectedVec expected_{id}(void) {{
    size_t count = sizeof(expected_{id}_data) / sizeof(expected_{id}_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_{id}_data, count * sizeof *data);

    return (ExpectedVec){{
        .data = data,
        .len  = count,
        .cap  = count,
    }};
}}
"#,
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
            Parser::Label(Label { inner, .. }) => inner.start_tokens(builder),
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
            Parser::Label(Label { inner, .. }) => inner.is_optional(builder),
        }
    }

    pub fn after_token(
        &self,
        token: &str,
        builder: &ParserBuilder,
    ) -> (Option<Parser>, Option<String>) {
        match self {
            Parser::Just(just) => {
                assert_eq!(just.0, token);
                (None, None)
            }
            Parser::Choice(choice) => choice.after_token(token, builder),
            Parser::Seq(seq) => seq.after_token(token, builder),
            Parser::Sep(_) => todo!(),
            Parser::Delim(_) => todo!(),
            Parser::Named(named) => named.after_token(token, builder),
            Parser::Skip(_) => todo!(),
            Parser::UnSkip(_) => todo!(),
            Parser::Optional(optional) => optional.after_token(token, builder),
            Parser::FoldOnce(fold_once) => fold_once.after_token(token, builder),
            Parser::Repeated(repeated) => repeated.after_token(token, builder),
            Parser::Rename(rename) => rename.after_token(token, builder),
            Parser::Empty => todo!(),
            Parser::Checkpoint(_) => panic!(
                "Tried to get after tokens for 'Checkpoint'. Didn't expect this to be needed??"
            ),
            Parser::Reference(n) => builder.get_var(n).unwrap().after_token(token, builder),
            Parser::Label(Label { inner, .. }) => inner.after_token(token, builder),
        }
    }

    pub fn remove_conflicts(&self, builder: &ParserBuilder, depth: usize) -> Parser {
        match self {
            Parser::Just(_) | Parser::Reference(_) => self.clone(),
            Parser::Choice(choice) => choice.remove_conflicts(builder, depth),
            Parser::Seq(seq) => seq.remove_conflicts(builder, depth),
            Parser::Sep(sep) => sep.remove_conflicts(builder, depth),
            Parser::Named(named) => named.remove_conflicts(builder, depth),
            Parser::Skip(skip) => skip.remove_conflicts(builder, depth),
            Parser::UnSkip(un_skip) => un_skip.remove_conflicts(builder, depth),
            Parser::Optional(optional) => optional.remove_conflicts(builder, depth),
            Parser::FoldOnce(fold_once) => fold_once.remove_conflicts(builder, depth),
            Parser::Repeated(repeated) => repeated.remove_conflicts(builder, depth),
            Parser::Rename(rename) => rename.remove_conflicts(builder, depth),
            Parser::Checkpoint(_) | Parser::Delim(_) => todo!(),
            Parser::Label(Label { name, inner }) => Parser::Label(Label {
                name: name.to_string(),
                inner: Box::new(inner.remove_conflicts(builder, depth)),
            }),
            Parser::Empty => todo!(),
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
        let mut src_file = Builder::new()
            .suffix(shared_lib_suffix())
            .tempfile()
            .unwrap();
        write!(&mut src_file, "{src}").unwrap();
        let src_file_path = src_file.path();
        let lib = Builder::new().suffix(".so").tempfile().unwrap();
        let lib_path = lib.path();
        cli::build::build(src_file_path, lib_path);
        CompiledLang::load(lib_path)
    }

    pub fn shared_lib_suffix() -> &'static str {
        #[cfg(target_os = "macos")]
        {
            ".dylib"
        }
        #[cfg(target_os = "linux")]
        {
            ".so"
        }
        #[cfg(windows)]
        {
            ".dll"
        }
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
            if let Node::Lexeme(l) | Node::Skipped(l) = $node {
                assert_eq!($lang.token_name(&l.kind), stringify!($name));
            } else {
                panic!("Expected a lexeme but found {:?}", $node);
            };
        }};
    }
}
