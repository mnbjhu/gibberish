# Gibberish Language Reference

This document describes the **Gibberish grammar language**: how tokens, keywords, and parsers are defined, and how parser expressions are composed.

Gibberish grammars are declarative and compositional. They describe _structure_ and _recovery boundaries_, not just recognition rules.

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

Keywords are identifiers with special meaning at the grammar level. They are lexed as identifiers and promoted during parsing.

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

Produces ("name+123"):

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

Produces a flatter tree without `_term` groups.

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

- Each element is attempted sequentially
- Missing elements may be synthesized
- Unexpected tokens are recorded and skipped until recovery

Sequences are **recovery-aware**: encountering a delimiter early produces a `Missing` node rather than a hard failure.

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

## Repetition (`repeated`)

```gibberish
parser stmts = stmt.repeated();
```

A repeated parser matches zero or more occurrences of its inner parser.

- Parsing stops on `BREAK(inner)` or EOF
- Missing elements may be generated when breaking early
- Enables recovery between adjacent constructs (e.g. statements)

---

## Separation (`sep_by`)

```gibberish
parser list = item.sep_by(comma);
```

Matches zero or more `item`s separated by `comma`.

- Both `item` and `sep` have recovery boundaries
- Missing items or separators are synthesized independently
- Allows mutual recovery between items and separators

---

## Delimited Parsers (`delim_by`)

```gibberish
parser array =
  item.sep_by(comma).delim_by(l_bracket, r_bracket);
```

Adds explicit opening and closing delimiters.

- The opening delimiter is expected first
- The closing delimiter acts as a strong recovery boundary
- Missing closing delimiters are synthesized when necessary

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

## Complete Example

```gibberish
keyword true;
keyword false;

token whitespace = "[ \t\n\f]+";
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
