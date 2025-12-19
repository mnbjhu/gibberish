# Gibberish

Gibberish is a **parser combinator language and compiler** designed to produce **lossless syntax trees (LSTs)** with robust, structured error recovery. It is built for tooling use-cases such as IDEs, language servers, formatters, and linters—where incomplete or incorrect source code must still be parsed meaningfully.

Unlike traditional parser combinator libraries that fail fast and discard structure on errors, Gibberish always produces a tree. Missing and unexpected syntax is represented explicitly, making it possible to reason about and recover from errors without backtracking or global failure.

---

## Getting Started

### Installing the Compiler

Prebuilt binaries are available on the **GitHub Releases** page.

- Download the appropriate binary for your platform
- Place it somewhere on your `$PATH`
- The executable is called `gibberish`

> At the moment, building from source is possible but not yet well-documented. Using a release binary is the recommended way to get started.

---

### Trying an Example Grammar

The fastest way to understand Gibberish is to look at and run the example grammars.

Examples live in:

```
docs/examples/
```

For example, the JSON grammar can be parsed and tested against an input file:

```sh
gibberish parse examples/test.json --parser docs/examples/json.gib
```

This will print the **lossless syntax tree**, including errors, skipped tokens, and structure.

---

### Common Workflows

**Lex a file**

```sh
gibberish lex input.txt
```

**Parse a file and inspect the tree**

```sh
gibberish parse input.txt --parser grammar.gib
```

**Hide tokens or errors for readability**

```sh
gibberish parse input.txt --hide-tokens
gibberish parse input.txt --hide-errors
```

**Watch a file while editing**

```sh
gibberish watch input.txt --parser grammar.gib
```

This is especially useful when developing or debugging grammars.

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
  Designed from the ground up to support IDEs, diagnostics, and formatting.

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

## Documentation (Early & Evolving)

The documentation is still **early-stage and evolving**. It reflects the current implementation but is not yet exhaustive or fully polished. Expect rough edges, missing sections, and ongoing changes.

That said, the following documents capture the core ideas accurately:

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

Gibberish is under active development.

- The **core parsing model is stable**
- The **grammar language may still change**
- The **documentation is incomplete and rough**

If something feels underspecified, it probably is—feedback and experimentation are encouraged.

---

## License

[Specify license here]

```

```
