# Error Recovery Model

This document describes how **Gibberish detects, represents, and recovers from syntax errors** while still producing a complete lossless syntax tree (LST).

Error recovery is not an add-on in Gibberish; it is a core design constraint. All parsers are expected to cooperate with the recovery model.

---

## Design Goals

The error recovery system is designed to:

- Always produce a syntax tree
- Preserve as much structure as possible
- Localize errors to the smallest reasonable scope
- Avoid global backtracking or parser resets
- Support tooling use-cases (IDEs, diagnostics, formatting)

---

## Lossless Errors

Gibberish represents errors _in the tree_, not as side effects.

There are two primary error node types:

- **`Missing`** — something was expected but not found
- **`Unexpected`** — something was found but not expected

Both are first-class `Node` variants.

---

## Unexpected Nodes

An `Unexpected` node represents one or more tokens that could not be parsed at the current position.

### Creation

Unexpected nodes are created when:

- A token does not match the current parser’s expectation
- No delimiter forces an immediate `BREAK`

The token is consumed and recorded instead of aborting parsing.

### Accumulation

If multiple unexpected tokens are encountered consecutively, they are grouped into a single `Unexpected` node:

```
Unexpected
  int: "123"
  ident: "abc"
```

This avoids creating long chains of single-token errors.

---

## Missing Nodes

A `Missing` node represents a syntactic element that was expected but absent.

### Creation

Missing nodes are created when:

- A delimiter is encountered before the expected element
- A parser completes without finding a required component
- A repeated or separated parser breaks early

The node records _what was expected_, not how parsing failed.

```
Missing: comma
```

### Labels

The contents of a `Missing` node are influenced by:

- The parser’s natural expectation
- Any explicit `labelled(...)` overrides

This allows grammars to produce meaningful diagnostics.

---

## Delimiters as Recovery Boundaries

Delimiters define **where a parser is allowed to recover** and **where it must stop**.

Each delimiter corresponds to a parser’s peeking condition (e.g. `]`, `}`, `,`, or the start of another construct).

---

## BREAK Ownership

When a delimiter is encountered, it produces a `BREAK(index)`.

- If the delimiter was introduced by the _current parser_, it may be handled locally
- If the delimiter predates the parser, it must be returned immediately

This establishes clear ownership of recovery responsibilities.

---

## Example: Sequence Recovery

Consider the sequence:

```gibberish
l_bracket + ident + r_bracket
```

### Input: `[]`

- `l_bracket` succeeds
- `ident` sees `r_bracket`
- `r_bracket` is a delimiter
- `ident` is marked as `Missing`

The parser does **not** consume `]` prematurely.

---

### Input: `[123 abc]`

- `l_bracket` succeeds
- `ident` sees `123`
- `123` is not a delimiter
- Token is consumed as `Unexpected`
- Parsing continues until `ident` succeeds or a delimiter is found

---

## Example: `sep_by` Recovery

```gibberish
parser list = item.sep_by(comma);
```

### Missing Separator

```
item item
```

When parsing the second `item`:

- `comma` is expected
- `item` start is encountered instead
- A `Missing: comma` node is created
- Parsing continues with the next `item`

---

### Missing Item

```
item , , item
```

- After the first `comma`, `item` is expected
- Another `comma` is encountered
- A `Missing: item` node is created
- Parsing continues

---

## Repetition and Early Termination

Repeated parsers introduce their own delimiters.

```gibberish
parser stmts = stmt.repeated();
```

If a new `stmt` begins while parsing the previous one:

- The inner parser encounters a delimiter
- A `BREAK(stmt)` is returned
- Missing components of the first statement are synthesized
- Parsing continues with the next statement

---

## End-of-File Recovery

EOF is treated as an implicit delimiter.

When EOF is encountered:

- Active parsers may generate missing nodes
- Open delimiters are closed
- Parsing terminates cleanly

This ensures even truncated files produce valid trees.

---

## Skipped Tokens and Errors

Skipped tokens (e.g. whitespace) do not participate in recovery decisions.

- They are consumed as `Skip` nodes
- They do not trigger or suppress `BREAK`s
- Errors are attributed to the surrounding structure

---

## Guarantees

The error recovery model guarantees that:

- Parsing always makes forward progress
- Every token appears exactly once in the tree
- Errors are explicit and localized
- The tree remains structurally meaningful

---

## Summary

Gibberish’s error recovery model is based on:

- Lossless error representation
- Delimiter-scoped recovery
- Explicit ownership via `BREAK`
- Deterministic, single-pass parsing

This makes Gibberish particularly well-suited for language tooling, where partial and invalid input is the norm.
