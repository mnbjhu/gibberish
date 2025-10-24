use std::fmt::Write;

pub mod just;

pub trait ParserBuilder {
    fn build_parse(&self, id: usize, f: &mut impl Write);
    fn build_peak(&self, id: usize, f: &mut impl Write);
    fn build_expected(&self, id: usize, f: &mut impl Write);
}
