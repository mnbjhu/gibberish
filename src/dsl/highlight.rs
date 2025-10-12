use crate::{
    dsl::{
        ast::stmt::highlight::QueryAst,
        lexer::RuntimeLang,
        lst::{lang::DslLang, query::query_parser},
        parser::ParserBuilder,
    },
    lsp::semantic_tokens::TokenKind,
    parser::state::ParserState,
    query::Query,
};

impl<'a> QueryAst<'a> {
    pub fn build(&self, builder: &ParserBuilder<'a>) -> Query<RuntimeLang, TokenKind> {
        match self {
            QueryAst::Group(ast) => {
                let name = ast.name();

                if let Some(p) = builder.vars.iter().position(|it| it.0 == name.text) {
                    Query::Group {
                        name: p as u32,
                        children: ast.sub_queries().map(|it| it.build(builder)).collect(),
                    }
                } else {
                    let tok = builder
                        .cache
                        .lang
                        .lexer
                        .tokens
                        .iter()
                        .position(|(n, _)| *n == name.text);
                    if tok.is_none() {
                        builder.error("Name not found", name.span.clone());
                        panic!("Unable to build parser")
                    }
                    Query::Token {
                        kind: tok.unwrap() as u32,
                    }
                }
            }
            QueryAst::Label(ast) => {
                let token_kind = match ast.name() {
                    "property" => TokenKind::Property,
                    "keyword" => TokenKind::Keyword,
                    "var" => TokenKind::Var,
                    "string" => TokenKind::String,
                    "number" => TokenKind::Number,
                    "function" => TokenKind::Func,
                    it => panic!("Unsupported token kind {it}"),
                };
                Query::Data {
                    query: Box::new(ast.query().build(builder)),
                    data: token_kind,
                }
            }
        }
    }
}
