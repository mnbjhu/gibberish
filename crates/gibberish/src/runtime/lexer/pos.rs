#[derive(Debug, Clone, Copy, PartialEq, Eq, Default, PartialOrd)]
pub struct Pos {
    pub offset: usize,
    pub char: usize,
    pub line: usize,
}

impl Pos {
    pub const fn zero() -> Pos {
        Pos {
            offset: 0,
            char: 0,
            line: 0,
        }
    }

    pub const fn non_newline() -> Pos {
        Pos {
            offset: 1,
            char: 1,
            line: 0,
        }
    }

    pub const fn newline() -> Pos {
        Pos {
            offset: 1,
            char: 0,
            line: 1,
        }
    }
}

impl std::ops::Add for Pos {
    type Output = Pos;

    fn add(self, rhs: Self) -> Self::Output {
        let offset = self.offset + rhs.offset;
        if rhs.line > 0 {
            Pos {
                offset,
                char: rhs.char,
                line: self.line + rhs.line,
            }
        } else {
            Pos {
                offset,
                char: self.char + rhs.char,
                line: self.line,
            }
        }
    }
}

impl std::ops::AddAssign for Pos {
    fn add_assign(&mut self, rhs: Self) {
        *self = *self + rhs;
    }
}
