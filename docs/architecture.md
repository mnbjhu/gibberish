# Architecture & Runtime Model

This document describes the **runtime architecture of the Gibberish parser**. It focuses on how parsing is executed, how state is managed, and how lossless syntax trees (LSTs) and error recovery are implemented.

This is not a language reference; instead, it explains _how_ Gibberish works under the hood.

---

## Overview

At runtime, Gibberish operates as a collection of cooperating parsers that all mutate a shared `ParserState`. Parsing is **single-pass**, **deterministic**, and **non-backtracking**.

Rather than succeeding or failing outright, parsers communicate via:

- Explicit state mutation
- Structured delimiters
- Integer return values (`OK`, `ERR`, `BREAK`)

The result of parsing is always a **lossless syntax tree**, even in the presence of severe syntax errors.

---

## Parser State

All parsers operate on a shared mutable `ParserState`.

### State Components

The parser state consists of:

- **Token array**
  The full stream of tokens produced by the lexer.

- **Node stack**
  A stack of partially-constructed `Node`s. The top of the stack is the _current group_.

- **Current offset**
  A `u64` index into the token array.

- **Delimiter stack**
  A stack of delimiter sentinels used to control recovery and termination.

- **Skip set**
  A set of token kinds that should be skipped (but still recorded).

> **Implementation note**
> The offset is a `u64`. Arrays are represented as three machine words (pointer, length, capacity), totaling 24 bytes.

---

## Nodes and the Lossless Syntax Tree

The output of parsing is a **lossless syntax tree (LST)**. Every token and structural decision is represented explicitly.

### Node Kinds

Conceptually, a `Node` is an enum with the following variants:

- **Lexeme**
  A successfully parsed token. Contains:

  - token kind
  - span
  - source text

- **Group**
  A syntactic construct (named or unnamed). Contains:

  - group kind
  - ordered list of child nodes

- **Missing**
  Represents a syntactic element that was expected but not found. Contains:

  - list of expected parser or token identifiers

- **Unexpected**
  Represents tokens that could not be parsed at the current position. Contains:

  - list of lexemes

- **Skip**
  A skipped token (e.g. whitespace or comments). Semantically identical to `Lexeme` but marked as skipped.

> **Implementation note**
> Each `Node` occupies 32 bytes.

---

## Core State Operations

Parsers interact with the runtime exclusively through a fixed set of primitive operations.

---

### Token Inspection

#### `Current`

Returns the kind of the current token at the parser offset.

- Used for lookahead and branching
- Used by delimiters to detect recovery boundaries

---

### Token Consumption

#### `Bump`

- Increments the offset
- Converts the current token into a `Lexeme`
- Appends it to the current group

#### `BumpSkipped`

Same as `Bump`, but creates a `Skip` node instead of a `Lexeme`.

#### `BumpError`

- Increments the offset
- Records the token as unexpected

If the last node in the current group is already an `Unexpected` node, the token is appended to it. Otherwise, a new `Unexpected` node is created.

---

### Group Management

#### `EnterGroup(name)`

Pushes a new, empty `Group` node onto the node stack. This group becomes the _current group_.

#### `ExitGroup`

Pops the current group from the stack and appends it to the parent group.

---

### Skipping Tokens

#### `Skip(token_kind)`

Adds a token kind to the skip set.

- Returns whether the token kind was already skipped
- Enables correct restoration in nested contexts

#### `Unskip(token_kind)`

Removes a token kind from the skip set.

Skipped tokens are still consumed and emitted as `Skip` nodes.

---

## Delimiters

Delimiters are the core mechanism used to control recovery and termination.

A delimiter is a _sentinel_ representing a parser’s expectation of when parsing should stop. Each delimiter corresponds to a parser’s **peeking condition**.

### Delimiter Stack

- Delimiters are pushed when parsers begin
- Delimiters are popped when parsers finish
- The stack encodes nested recovery scopes

---

## Parser Results

Parsers return an integer value that controls outer parsing behavior.

- **`OK`** (`0`)
  The parser successfully consumed what it was responsible for.

- **`ERR`** (`1`)
  The parser failed in a way it could not recover from locally.

- **`BREAK(index)`** (`>= 2`)
  Parsing should stop because a delimiter was encountered.

`BREAK(EOF)` is represented by `2`.

---

## BREAK Semantics

When a parser begins execution:

- It records the current delimiter stack depth
- It may push one or more delimiters

While parsing:

- If a delimiter **older than the parser** is encountered, the parser must immediately return that `BREAK`
- If the delimiter was introduced by the parser itself, it may be handled internally

This enforces _ownership_ of errors and recovery.

---

## Recovery Model

Unexpected tokens are consumed eagerly and recorded as `Unexpected` nodes unless a delimiter forces termination.

Missing nodes are synthesized when:

- A delimiter is encountered where a parser expected input
- A parser completes without finding required elements

This ensures that:

- Parsing always makes forward progress
- Structure is preserved even in broken input
- Errors are localized and explicit

---

## Why This Model?

This architecture avoids:

- Global backtracking
- Implicit failure propagation
- Ambiguous recovery behavior

In exchange, it provides:

- Deterministic parsing
- Clear recovery boundaries
- Trees suitable for IDEs, formatters, and analyzers

The complexity is explicit, but controlled.

---

## Next Sections

- **Parser Combinators** → `combinators.md`
- **Error Recovery Model** → `error-recovery.md`
