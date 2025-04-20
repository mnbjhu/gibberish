use notify::{Event, RecursiveMode, Result as NotifyResult, Watcher as _, recommended_watcher};
use std::{
    fs,
    io::{Write, stdout},
    path::Path,
    sync::mpsc,
};

use crate::json::parser::json_parser;

/// ANSI-clear + move cursor to top-left
fn clear_screen() {
    // \x1B[2J = clear screen, \x1B[1;1H = cursor home
    print!("\x1B[2J\x1B[1;1H");
    stdout().flush().unwrap();
}

pub fn watch(path: &Path) -> NotifyResult<()> {
    // 1) Path to watch from CLI
    // 2) Instantiate your JSON parser (Rc-based is fine here)
    let parser = json_parser();

    // 3) Initial parse
    clear_screen();
    let text = fs::read_to_string(path).expect("read error");
    parser.parse(&text).debug_print();

    // 4) Set up the channel and watcher
    let (tx, rx) = mpsc::channel::<NotifyResult<Event>>();
    let mut watcher = recommended_watcher(tx)?;
    watcher.watch(path, RecursiveMode::NonRecursive)?;

    // 5) Event loop on main thread
    for res in rx {
        match res {
            Ok(event) => {
                if event.kind.is_access() {
                    continue;
                }
                clear_screen();
                let text = fs::read_to_string(path).expect("read error");
                parser.parse(&text).debug_print();
            }
            Err(e) => eprintln!("watch error: {:?}", e),
        }
    }

    Ok(())
}
