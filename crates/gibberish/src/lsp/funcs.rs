pub struct FuncDef {
    pub name: &'static str,
    pub args: &'static [FuncArg],
}

pub struct FuncArg {
    pub name: &'static str,
    pub ty: Type,
}

impl FuncArg {
    pub const fn parser(name: &'static str) -> Self {
        FuncArg {
            name,
            ty: Type::Parser,
        }
    }

    pub const fn token(name: &'static str) -> Self {
        FuncArg {
            name,
            ty: Type::Token,
        }
    }

    pub const fn label(name: &'static str) -> Self {
        FuncArg {
            name,
            ty: Type::Label,
        }
    }
}

pub enum Type {
    Token,
    Parser,
    Label,
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
        args: &[FuncArg::parser("open"), FuncArg::parser("close")],
    },
    FuncDef {
        name: "sep_by",
        args: &[FuncArg::parser("seperator")],
    },
    FuncDef {
        name: "skip",
        args: &[FuncArg::token("token")],
    },
    FuncDef {
        name: "unskip",
        args: &[FuncArg::token("token")],
    },
    FuncDef {
        name: "labelled",
        args: &[FuncArg::label("name")],
    },
];
