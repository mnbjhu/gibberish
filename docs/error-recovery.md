# Error Recovery Model

This document describes how **Gibberish detects, represents, and recovers from syntax errors** while still producing a complete lossless syntax tree (LST).

Error recovery is not an add-on in Gibberish; it is a core design constraint. All parsers are expected to cooperate with the recovery model.

> **Note**
> This document reflects the current parsing model but is still **evolving**. The high-level behavior is stable, but details may change as the system is refined.

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

Both are first-class `Node` variants and participate in normal tree structure.

---

## Unexpected Nodes

An `Unexpected` node represents one or more tokens that were consumed even though they did not match the current parser’s expectation.

### Creation

Unexpected nodes are created when:

- A parser has already committed (consumed a non-skipped token)
- The next token does not match the expected input
- No `BREAK` occurs (i.e. the parser is not allowed to decline)

In this situation, the token is consumed and recorded rather than causing parsing to stop.

### Accumulation

If multiple unexpected tokens are encountered consecutively, they are grouped into a single `Unexpected` node:

```
Unexpected
  int: "123"
  ident: "abc"
```

This avoids creating long chains of single-token error nodes.

---

## Missing Nodes

A `Missing` node represents a syntactic element that was expected but absent.

### Creation

Missing nodes are synthesized only **after a parser has committed**.

They are created when:

- A delimiter is encountered after commitment
- A parser completes without finding a required component
- A repeated or separated parser terminates early

The node records _what was expected_, not how parsing failed.

```
Missing: comma
```

### Labels

The contents of a `Missing` node are influenced by:

- The parser’s natural expectation
- Any explicit `labelled(...)` overrides

This allows grammars to produce meaningful and stable diagnostics.

---

## Delimiters and Recovery

Delimiters do **not** force parsers to stop once they have begun parsing.

Instead, delimiters serve two related purposes:

1. They determine whether a parser is allowed to _begin_ parsing
2. After commitment, they influence where `Missing` nodes are synthesized

Delimiters correspond to parser _start conditions_, not hard termination points.

---

## BREAK and Error Ownership

A `BREAK` represents a parser’s refusal to start, not an error during parsing.

- A `BREAK` may only occur before a parser consumes any non-skipped token
- Once a parser commits, it will never return `BREAK`

Ownership rules:

- If the first non-skipped token matches a delimiter older than the parser, the parser returns that `BREAK`
- If the parser introduced the delimiter, it may handle it internally

This ensures that errors are handled by the smallest responsible parser.

---

## Example: Sequence Recovery

Consider the sequence:

```gibberish
l_bracket + ident + r_bracket
```

### Input: `[]`

- `l_bracket` commits
- `ident` sees `r_bracket`
- The parser is already committed
- `ident` is synthesized as `Missing`
- `r_bracket` is consumed normally

The parser does **not** produce a `BREAK` and does not abandon parsing.

---

### Input: `[123 abc]`

- `l_bracket` commits
- `ident` sees `123`
- `123` is not a delimiter
- Token is consumed as `Unexpected`
- Parsing continues until `ident` succeeds or the sequence completes

---

## Example: `sep_by` Recovery

```gibberish
parser list = item.sep_by(comma);
```

### Missing Separator

```
item item
```

- `item` commits
- `comma` is expected
- Start of another `item` is encountered
- A `Missing: comma` node is synthesized
- Parsing continues with the next `item`

---

### Missing Item

```
item , , item
```

- After the first `comma`, `item` is expected
- Another `comma` is encountered
- The parser is committed
- A `Missing: item` node is synthesized
- Parsing continues

---

## Repetition and Early Termination

Repeated parsers introduce delimiters representing the start of another element.

```gibberish
parser stmts = stmt.repeated();
```

If a new `stmt` begins while parsing the previous one:

- The inner parser has already committed
- Encountering a start delimiter causes missing components to be synthesized
- Parsing continues with the next statement

No `BREAK` is produced once parsing has begun.

---

## End-of-File Recovery

EOF acts like an implicit delimiter.

When EOF is encountered:

- Active parsers synthesize any required `Missing` nodes
- Open constructs are closed
- Parsing terminates cleanly

This ensures that even truncated files produce valid trees.

---

## Skipped Tokens and Errors

Skipped tokens (e.g. whitespace or comments) do not participate in commitment or `BREAK` decisions.

- They are consumed as `Skip` nodes
- They do not trigger or suppress `BREAK`
- Errors are attributed to the surrounding syntactic structure

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
- Commit-on-first-token semantics
- Delimiter-guided synthesis of missing structure
- Deterministic, single-pass parsing

This makes Gibberish particularly well-suited for language tooling, where partial and invalid input is the norm.
