use gibberish_core::lang::CompiledLang;
use notify::{Event, RecursiveMode, Result as NotifyResult, Watcher as _, recommended_watcher};
use std::{
    fs,
    io::{Write, stdout},
    path::Path,
    sync::mpsc,
};

use crate::bindings::parse;

/// ANSI-clear + move cursor to top-left
fn clear_screen() {
    // \x1B[2J = clear screen, \x1B[1;1H = cursor home
    print!("\x1B[2J\x1B[1;1H");
    stdout().flush().unwrap();
}

pub fn watch(parser: &Path, path: &Path, errors: bool, tokens: bool) -> NotifyResult<()> {
    let lang = CompiledLang::load(parser);
    clear_screen();
    let text = fs::read_to_string(path).unwrap();
    parse(&lang, &text).debug_print(errors, tokens, &lang);
    let (tx, rx) = mpsc::channel::<NotifyResult<Event>>();
    let mut watcher = recommended_watcher(tx)?;
    watcher.watch(path, RecursiveMode::NonRecursive)?;
    for res in rx {
        match res {
            Ok(event) => {
                if event.kind.is_access() {
                    continue;
                }
                clear_screen();
                let text = fs::read_to_string(path).expect("read error");
                parse(&lang, &text).debug_print(errors, tokens, &lang);
            }
            Err(e) => eprintln!("watch error: {:?}", e),
        }
    }

    Ok(())
}
