# Architecture & Runtime Model

This document describes the **runtime architecture of the Gibberish parser**. It focuses on how parsing is executed, how state is managed, and how lossless syntax trees (LSTs) and error recovery are implemented.

This is not a language reference; instead, it explains _how_ Gibberish works under the hood, in order to explain how the generated parsers will behave.

> **Note**
> This document reflects the current implementation but is still **evolving**. Terminology and details may change as the parsing model is refined.

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
  A stack of delimiter sentinels used to detect recovery boundaries.

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

Delimiters are the core mechanism used to coordinate recovery between parsers.

A delimiter is a _sentinel_ representing a parser’s **start condition** rather than a hard stop. Delimiters are used to determine whether a parser should _begin_, not to force it to stop once committed.

### Delimiter Stack

- Delimiters are pushed by parsers to advertise their start tokens
- Delimiters are removed dynamically as parsing progresses (e.g. in sequences)
- The stack represents nested parsing expectations, not strict termination points

Delimiters are consulted **only before a parser commits**. Once a parser has consumed any non-skipped token, delimiters no longer cause a `BREAK`.

---

## Parser Results

Parsers return an integer value that communicates how outer parsers should proceed.

- **`OK`** (`0`)
  The parser consumed at least one **non-skipped** token. Once a parser commits, it will always return `OK`, even if it later encounters delimiters and must synthesize `Missing` nodes.

- **`ERR`** (`1`)
  The parser failed to parse its first non-skipped token but did not encounter a delimiter. This indicates that the token should generally be consumed as `Unexpected`. In the case of `choice`, `ERR` signals that the next alternative should be tried.

- **`BREAK(index)`** (`>= 2`)
  The parser declined to begin because the **first non-skipped token** matched a delimiter older than the parser.

`BREAK(EOF)` is represented by `2`.

---

## BREAK Semantics

A `BREAK` represents a refusal to start parsing, not a failure during parsing.

When a parser begins execution:

- It has not yet consumed any non-skipped tokens
- It may push delimiters advertising its start tokens

While parsing:

- If the **first non-skipped token** matches an older delimiter, the parser must immediately return that `BREAK`
- If the parser consumes any non-skipped token, it becomes _committed_ and will never return `BREAK`
- After commitment, delimiters are ignored for control flow and only influence error synthesis

This establishes clear ownership rules:

- Parsers may decline to start (`BREAK`)
- Parsers may not abandon work once started

---

## Recovery Model

Unexpected tokens are consumed eagerly and recorded as `Unexpected` nodes unless a parser declines to start via `BREAK`.

Missing nodes are synthesized when:

- A delimiter is encountered _after_ a parser has committed
- A parser completes without finding required elements

This ensures that:

- Parsing always makes forward progress
- Structure is preserved even in broken input
- Errors are localized and explicit

---

## Why This Model?

This architecture avoids:

- Global backtracking
- Parsers partially undoing work
- Ambiguous failure vs recovery semantics

In exchange, it provides:

- Deterministic parsing
- Explicit commitment points
- Trees suitable for IDEs, formatters, and analyzers

The complexity is explicit, but controlled.
