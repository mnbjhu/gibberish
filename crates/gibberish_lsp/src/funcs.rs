pub struct FuncDef {
    pub name: &'static str,
    pub args: &'static [&'static str],
}

pub const DEFAULT_FUNCS: &[FuncDef] = &[
    FuncDef {
        name: "or_not",
        args: &[],
    },
    FuncDef {
        name: "repeated",
        args: &[],
    },
    FuncDef {
        name: "delim_by",
        args: &["open", "close"],
    },
    FuncDef {
        name: "sep_by",
        args: &["seperator"],
    },
    FuncDef {
        name: "skip",
        args: &["token"],
    },
    FuncDef {
        name: "unskip",
        args: &["token"],
    },
];
