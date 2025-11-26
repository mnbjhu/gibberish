use gibberish_gibberish_parser::Gibberish;
use notify::{Event, RecursiveMode, Result as NotifyResult, Watcher as _, recommended_watcher};
use std::{
    fs,
    io::{Write, stdout},
    path::Path,
    sync::mpsc,
};

use crate::api::ptr::ParserCache;

/// ANSI-clear + move cursor to top-left
fn clear_screen() {
    // \x1B[2J = clear screen, \x1B[1;1H = cursor home
    print!("\x1B[2J\x1B[1;1H");
    stdout().flush().unwrap();
}

pub fn watch(path: &Path, errors: bool, tokens: bool) -> NotifyResult<()> {
    clear_screen();
    let text = fs::read_to_string(path).expect("read error");
    Gibberish::parse(&text).debug_print(errors, tokens, &Gibberish);
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
                Gibberish::parse(&text).debug_print(errors, tokens, &Gibberish);
            }
            Err(e) => eprintln!("watch error: {:?}", e),
        }
    }

    Ok(())
}
