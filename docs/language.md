# Gibberish Language Reference

This document describes the **Gibberish grammar language**: how tokens, keywords, and parsers are defined, and how parser expressions are composed.

Gibberish grammars are declarative and compositional. They describe _structure_ and _recovery boundaries_, not just recognition rules.

> **Note**
> This documentation is still **early and evolving**. The core ideas are stable, but details and APIs may change as the language matures.

---

## Source Files

Gibberish grammars are defined in `.gib` files. A grammar file consists of:

- Token definitions
- Keyword definitions
- Parser definitions

Order generally does not matter, except that referenced names must exist.

---

## Tokens

Tokens define the lexical structure of the language. Each token is backed by a regular expression.

### Definition Syntax

```gibberish
token <name> = "<regex>";
```

### Example

```gibberish
token semi = ";";
token int = "[0-9]+";
token ident = "[_a-zA-Z][_a-zA-Z0-9]*";
token whitespace = "[ \t\n\f]+";
```

### Notes

- Token regexes are matched left-to-right over the input
- Tokens are **lossless**: all matched text is preserved
- Tokens are not skipped by default

Skipping is handled at the **parser** level, not the lexer level.

---

## Keywords

Keywords are just a convenient way a creating tokens for specific identifier.

### Definition Syntax

```gibberish
keyword <name>;
```

### Example

```gibberish
keyword select;
keyword delete;
keyword from;
```

### Notes

- Keywords share the same underlying token kind as identifiers
- Keyword matching occurs during parsing, not lexing
- This avoids lexer ambiguity and simplifies grammar composition

---

## Parsers

Parsers define the syntactic structure of the language. Each parser is defined in terms of other parsers, tokens, and combinators.

### Definition Syntax

```gibberish
parser <name> = <expr>;
```

### Example

```gibberish
parser number = int;
parser name = ident;
parser assignment = name + equals + number;
```

---

## Named vs Internal Parsers

Parser names control grouping behavior in the resulting syntax tree.

### Named Parsers

Parsers whose names **do not** start with `_` automatically introduce a `Group` node in the syntax tree.

```gibberish
parser term = ident | num;
parser root = term + plus + term;
```

Produces (`name+123`):

```
root
  term
    ident
  plus
  term
    num
```

### Internal Parsers

Parsers whose names **start with `_`** are considered internal and do _not_ create groups.

```gibberish
parser _term = number | ident;
parser root = _term + plus + _term;
```

Produces a flatter tree without `_term` groups:

```
root
  ident
  plus
  num
```

---

## Parser Expressions

Parser expressions are composed using operators and method-style combinators.

---

## Sequence (`+`)

```gibberish
parser pair = left + right;
```

A sequence parser matches its sub-parsers in order.

### Semantics

- Each element is attempted sequentially
- Missing elements may be synthesized
- Unexpected tokens are recorded and skipped until recovery

### Recovery Behavior

Internally, a sequence pushes **all elements except the first** onto the delimiter stack when it begins. As each element successfully parses, the next delimiter is removed.

This means:

- Later elements in the sequence act as recovery boundaries
- Earlier elements may recover against later ones
- No special recovery logic is required for higher-level combinators

This mechanism is also used by `delim_by`.

---

## Choice (`|`)

```gibberish
parser value = string | number | bool;
```

A choice parser tries each alternative until one succeeds.

- Failures contribute to error information
- No global backtracking is performed
- The first successful alternative wins

---

## Optional (`or_not`)

```gibberish
parser root = l_bracket + item.or_not() + r_bracket;
```

An optional parser attempts to parse its inner parser but **never produces a `Missing` node**.

### Semantics

- If the inner parser parses successfully, its result is included
- If it does not parse, parsing continues as if it were absent
- All other behavior (error recovery, unexpected tokens) is unchanged

### Effect on Sequence Start Tokens

When a sequence begins with one or more optional parsers, the **start tokens of the sequence change**.

```gibberish
parser func_def = _visibility_modifier.or_not() + func + ...;
```

If this sequence is used as a delimiter or recovery boundary:

- Both `_visibility_modifier` _and_ `func` are considered valid start tokens
- Encountering either will produce `BREAK(func_def)`

This ensures correct recovery behavior when optional prefixes are present.

---

## Repetition (`repeated`)

```gibberish
parser stmts = stmt.repeated();
```

A repeated parser matches one or more occurrences of its inner parser.

### Semantics

- Parsing stops on `BREAK(inner)` or EOF
- Missing elements may be generated when breaking early
- Enables recovery between adjacent constructs (e.g. statements)

> **Note**
> Currently, `repeated` requires at least one successful match. This is expected to change in the future to allow explicit minimum counts.

---

## Separation (`sep_by`)

```gibberish
parser list = item.sep_by(comma);
```

Matches one or more `item`s separated by `comma`.

### Semantics

- Both `item` and `sep` have recovery boundaries
- Missing items or separators are synthesized independently
- Allows mutual recovery between items and separators

> **Note**
> Like `repeated`, `sep_by` currently requires at least one `item`. This is likely to become configurable.

---

## Delimited Parsers (`delim_by`)

```gibberish
parser array =
  item.sep_by(comma).delim_by(l_bracket, r_bracket);
```

Delimited parsers add explicit opening and closing tokens.

### Implementation Note

`delim_by` is implemented internally using `seq`.

- The opening delimiter is the first element
- The closing delimiter participates in the sequence recovery model
- Missing closing delimiters are synthesized automatically

No special delimiter-specific recovery logic is required.

---

## Fold (`fold`)

```gibberish
parser sum = _expr fold (plus + _expr).repeated();
```

The `fold` parser is used when a parser should **conditionally introduce a group** based on what follows.

### Semantics

- Parsing begins by executing the left-hand parser (`_expr`)
- If no further input matches the folded part, no new group is created
- If at least part of the folded parser succeeds, a group named after the assignment (`sum`) is created

### Example

- Input: `x`

  - Produces whatever structure `_expr` creates

- Input: `x + y + z`
  - Produces a `sum` group containing all parsed content

> **Note**
> A `fold` expression is only valid at the top level of a `parser` assignment, as it relies on the parser name for grouping.

---

## Skipping Tokens (`skip` / `unskip`)

```gibberish
parser root = expr.skip(whitespace);
```

Adds a token kind to the skip set for the duration of the parser.

- Skipped tokens are still recorded as `Skip` nodes
- Skipping is scoped and nestable
- Useful for whitespace and comments

`unskip` removes a token kind from the skip set.

---

## Labels (`labelled`)

```gibberish
parser expr =
  (object | array | string | number).labelled(expr);
```

Overrides the default expected value used when generating `Missing` nodes.

- Improves diagnostics
- Does not affect parsing behavior

---

## Complete Example (json)

```gibberish
keyword true;
keyword false;

token whitespace = "\\s+";
token str = "\"[^\"]*\"";
token int = "[0-9]+";
token colon = ":";
token comma = ",";
token l_bracket = "\\[";
token r_bracket = "\\]";
token l_brace = "\\{";
token r_brace = "\\}";

parser string = str;
parser num = int;
parser bool = true | false;

parser array =
  _expr.sep_by(comma).delim_by(l_bracket, r_bracket);

parser field =
  str + colon + _expr;

parser object =
  field.sep_by(comma).delim_by(l_brace, r_brace);

parser _expr =
  (object | array | string | num | bool).labelled(expr);

parser root =
  _expr.skip(whitespace);
```
