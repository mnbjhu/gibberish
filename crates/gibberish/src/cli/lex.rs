use std::{collections::HashMap, fs, mem, path::Path, sync::mpsc};

use gibberish_dyn_lib::bindings::parse;
use gibberish_gibberish_parser::Gibberish;
use notify::{Event, RecursiveMode, Result as NotifyResult, Watcher as _, recommended_watcher};
use tower_lsp::lsp_types::DiagnosticSeverity;

use crate::{
    cli::{parse::load_parser, watch::clear_screen},
    runtime::lexer::LexerToken,
};

use gibberish_core::{lang::RawLang, node::Lexeme};
use gibberish_dyn_lib::bindings::lang::CompiledLang;

use crate::{cli::build::build_parser_from_src, runtime::lexer::Lexer};

pub fn lex(path: &Path) {
    let text = fs::read_to_string(path).unwrap();
    let lex = Gibberish::lex(&text);
    for tok in lex {
        tok.debug_at(0, &Gibberish, false);
    }
}

pub fn lex_custom(
    path: &Path,
    parser: &Path,
    min_severity: DiagnosticSeverity,
    runtime: bool,
    watch: bool,
) {
    let text = fs::read_to_string(path).unwrap();
    if runtime || watch {
        let parser = build_parser_from_src(parser, min_severity);
        let tokens = parser
            .lexer
            .iter()
            .cloned()
            .enumerate()
            .map(|(index, (name, regex))| LexerToken {
                id: index as u32,
                name,
                regex,
            })
            .collect();
        let lexer = Lexer { tokens };
        let mut lex_res = lexer.lex(text);
        if watch {
            for tok in &lex_res.tokens {
                println!(
                    "{name}:{len}:{lookahead}",
                    name = parser
                        .lexer
                        .get(tok.kind as usize)
                        .map(|(name, _)| name.as_str())
                        .unwrap_or("Err"),
                    len = tok.len,
                    lookahead = tok.lookahead
                )
            }
            let (tx, rx) = mpsc::channel::<NotifyResult<Event>>();
            let mut watcher = recommended_watcher(tx).unwrap();
            watcher.watch(path, RecursiveMode::NonRecursive).unwrap();
            for res in rx {
                match res {
                    Ok(event) => {
                        if event.kind.is_access() {
                            continue;
                        }
                        clear_screen();
                        let text = fs::read_to_string(path).expect("read error");
                        lex_res = lexer.lex(text);
                        for tok in &lex_res.tokens {
                            println!(
                                "{name}:{len}:{lookahead}",
                                name = parser
                                    .lexer
                                    .get(tok.kind as usize)
                                    .map(|(name, _)| name.as_str())
                                    .unwrap_or("Err"),
                                len = tok.len,
                                lookahead = tok.lookahead
                            )
                        }
                    }
                    Err(e) => eprintln!("watch error: {:?}", e),
                }
            }
        } else {
            for tok in &lex_res.tokens {
                println!(
                    "{name}:{len}:{lookahead}",
                    name = parser
                        .lexer
                        .get(tok.kind as usize)
                        .map(|(name, _)| name.as_str())
                        .unwrap_or("Err"),
                    len = tok.len,
                    lookahead = tok.lookahead
                )
            }
        }
    } else {
        let lang = load_parser(parser, min_severity);
        let lex = gibberish_dyn_lib::bindings::lex(&lang, &text);
        for tok in lex {
            unsafe {
                mem::transmute::<Lexeme<RawLang>, Lexeme<CompiledLang>>(Lexeme::from_data(
                    tok, &text,
                ))
                .debug_at(0, &lang, false)
            };
        }
    }
}
