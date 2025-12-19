# Gibberish

Gibberish is a **parser combinator language and compiler** designed to produce **lossless syntax trees (LSTs)** with robust, structured error recovery. It is built for tooling use-cases such as IDEs, language servers, formatters, and linters—where incomplete or incorrect source code must still be parsed meaningfully.

Unlike traditional parser combinator libraries that fail fast and discard structure on errors, Gibberish always produces a tree. Missing and unexpected syntax is represented explicitly, making it possible to reason about and recover from errors without backtracking or global failure.

---

## Key Features

- **Lossless Syntax Trees (LSTs)**
  Every token—including whitespace, skipped tokens, and errors—is preserved in the tree.

- **Structured Error Recovery**
  Missing and unexpected elements are first-class nodes, not side effects.

- **Deterministic Parsing Model**
  Parsing control flow is explicit and local, using delimiters and `BREAK`s instead of backtracking.

- **Parser Combinator Language**
  Grammars are written compositionally using sequences, choices, repetition, separators, and delimiters.

- **Tooling-Oriented**
  Designed from the ground up to support IDEs, incremental parsing, diagnostics, and formatting.

---

## The Gibberish Compiler CLI

The Gibberish compiler provides a set of tools for working with grammars and source files.

### Commands

- **`lex`**
  Lex a file and display the resulting tokens.

  ```sh
  gibberish lex <src> [--parser <parser>]
  ```

- **`parse`**
  Parse a file and display its lossless syntax tree.

  ```sh
  gibberish parse <path> [--hide-errors] [--hide-tokens] [--parser <parser>]
  ```

- **`watch`**
  Watch a file, reparse it on changes, and display the updated syntax tree.

  ```sh
  gibberish watch <path> [--hide-errors] [--hide-tokens] [--parser <parser>]
  ```

- **`build`**
  Compile a `.gib` grammar into a parser library.

  ```sh
  gibberish build <path> --output <output>
  ```

- **`generate`**
  Generate libraries and APIs from a grammar.

  ```sh
  gibberish generate <path>
  ```

- **`lsp`**
  Start the Gibberish language server.

  ```sh
  gibberish lsp
  ```

---

## What Makes Gibberish Different?

Most parser combinator systems revolve around _success vs failure_. Gibberish instead models parsing as **progress through structured boundaries**:

- Parsers return `OK`, `ERR`, or `BREAK`
- Delimiters define recovery points
- Errors are owned and handled locally
- Parsing continues whenever possible

This allows Gibberish to recover gracefully from deeply broken input while still producing a meaningful, navigable tree.

---

## Documentation

The full documentation is split into focused sections:

- **Architecture & Concepts**
  Parser state, nodes, delimiters, and `BREAK` semantics
  → `docs/architecture.md`

- **Language & Grammar Syntax**
  Tokens, keywords, parsers, and combinators
  → `docs/language.md`

- **Parser Combinators**
  Sequence, choice, repeated, `sep_by`, `delim_by`, skip, labelled
  → `docs/combinators.md`

- **Error Recovery Model**
  Missing vs unexpected nodes, delimiter interaction
  → `docs/error-recovery.md`

- **Examples**
  Complete grammars (JSON, SQL, etc.)
  → `docs/examples/`

---

## Status

Gibberish is under active development. The API and grammar language are still evolving, but the core parsing model and tree representation are stable enough for experimentation and tooling work.

---

## License

[Specify license here]
