# Gibberish

Gibberish is a **parser combinator language and compiler** designed to produce **lossless syntax trees (LSTs)** with robust, structured error recovery. It is built for tooling use-cases such as IDEs, language servers, formatters, and linters—where incomplete or incorrect source code must still be parsed meaningfully.

Unlike traditional parser combinator libraries that fail fast and discard structure on errors, Gibberish always produces a tree. Missing and unexpected syntax is represented explicitly, making it possible to reason about and recover from errors without backtracking or global failure.

```sh
gibberish parse bad.json --parser grammar.gib
```

![example](docs/svg/example.svg)

---

## Getting Started

### Prerequisites

Gibberish builds a C library and many of the commands rely on cc being present on the PATH.
For windows you'll need CL.

> **Note**
> Depending on a C compiler already seems like it's going to be a pain.
> There's likely a lot configuations which won't work under the current setup.
> However if this is the case you can generate the C instead, compile it to a shared lib and
> point the `gibberish` CLI to that instead.
> I think my plan is to build a Gibberish runtime for when you exeucte 'lex', 'parse', 'watch' etc
> to avoid these struggles.
> I'm hoping the current implementation is enough to demo the core ideas of the combinators.

---

### Installing the Compiler

Prebuilt binaries are available on the [**GitHub Releases**](https://github.com/mnbjhu/gibberish/releases) page.

- Download the appropriate binary for your platform
- Place it somewhere on your `$PATH`
- The executable is called `gibberish`

#### Building from source

```sh
git clone https://github.com/mnbjhu/gibberish
cd gibberish
cargo install --path crates/gibberish
```

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

This will print the **lossless syntax tree**, including structure, skipped tokens, and explicit error nodes.

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
  Parsers either refuse to start or commit and recover locally—no backtracking.

- **Parser Combinator Language**
  Grammars are written compositionally using sequences, choice, repetition, separation, and folding.

- **Tooling-Oriented by Design**
  Designed from the ground up for IDEs, diagnostics, formatting, and incremental workflows.

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
  Compile a `.gib` grammar into a parser library (requires `qbe`).

  ```sh
  gibberish build <path> --output <output>
  ```

- **`generate`**
  Generate libraries and APIs from a grammar (requires `qbe`).

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

Most parser combinator systems revolve around _success vs failure_. Gibberish instead models parsing as **commitment and local recovery**:

- Parsers may **refuse to start** (`BREAK` or `ERR`)
- Once a parser consumes input, it **must commit and finish responsibly** (`OK`)
- Parsers can tell child parsers to `BREAK` rather than `ERR` when failing to pass specific tokens.
- When a parser encounters a `BREAK` (that it wasn't the author of) the parser will **finish responsibly**
- Errors are synthesized structurally, not thrown

This allows Gibberish to recover gracefully from deeply broken input while still producing a meaningful, navigable tree.

---

## Documentation (Early & Evolving)

The documentation reflects the current implementation but is still **early-stage and evolving**. Expect rough edges and underspecified areas.

The following documents capture the core ideas accurately:

- **Architecture & Runtime Model**
  Parser state, commitment, delimiters, and `BREAK` semantics
  → [`docs/architecture.md`](docs/architecture.md)

- **Language & Grammar Syntax**
  Tokens, keywords, parsers, and grammar expressions
  → [`docs/language.md`](docs/language.md)

- **Error Recovery Model**
  Missing vs unexpected nodes, commitment, and recovery behavior
  → [`docs/error-recovery.md`](docs/error-recovery.md)

- **Examples**
  Complete grammars (JSON, SQL, etc.)
  → [`docs/examples/`](docs/examples/)

---

## Status

Gibberish is under active development.

- The **core parsing model is stable**
- The **grammar language may still change**
- The **documentation is incomplete and evolving**

If something feels underspecified, it probably is—feedback and experimentation are encouraged.
