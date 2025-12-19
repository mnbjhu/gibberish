# Gibberish

## Parser State

- Array of tokens
- Stack of `node`'s
- Current offset
- A stack of delims (references to the parsers peaking function)
- A set of tokens to skip
  Note: Offset is u64, each array is represented as 24 byte, 3x 8-byte ptr, len, cap

### Node

A node is any element in the generated LST (lossless syntax tree).
A node (and therefore the tree) can be described by an enum with the following variants:

- Lexeme: A token kind along with the span and the text
- Group: A group kind along with an array of other `node`'s
- Missing: Represents something missing from the LST, is an array of expected (u64)
- Unexpected: Represents something unexpected in the LST, is an array of `lexeme`
- Skip: The same as lexeme but marked as skipped

Note: Node is represented as 32 bytes

### Operations

The parser API relies on using a set of operations on the state.

#### Current

Gets the current token kind and is used by the parsers to check for errors and make decisions

#### Bump

When bump is called it increments the offset and put the current token into the current group (consuming that token).

#### BumpSkipped

Same as `Bump` but creates a `Skip` rather than a `Lexeme`.

#### BumpError

Bump error will also increment the offset and will create a new `Unexpected` node with the token UNLESS
the last element the current group was an `Unexpected` node. In which case it will push the new `Lexeme`
onto the `Unexpected`.

#### EnterGroup(name)

Will push a new, empty, group node onto the node stack with `name`.
This will make the 'current group' this new group, so any bumps will go into this group.

#### ExitGroup

Will pop the 'current group' from the stack and 'bump' it into the next group in the stack.

#### Skip

Will push a token to the skip set (also indicates if the token was already skipped to tell the current call stack whether to pop the token after)

#### Unskip

Oppoisite of `Skip`

#### PushDelim(delim)

Push a delim into the delim stack

#### PopDelim

Pops a delim from the delim stack

### Lexer

The lexer used by the parser is define by `token` and `keyword` definitions:

e.g.

```
token semi = ";";
token num = "[0-9]+";
token ws = "\s+";
token ident = "[_a-zA-Z][_a-zA-Z0-9]*";

keyword select;
keyword delete;
keyword from;
```

When lexing

```sql
select 123 from table;
```

Will produce these tokens:

```
ident: "select"@0..6
ws: " "@6..7
num: "123"@7..10
ws: " "@10..11
ident: "from"@11..15
ws: " "@15..16
ident: "table"@16..21
semi: ";"@21..22
ws: "\n"@22..23
```

### Parser API

Gibberish is a parser combinator and to work each parser must follow a strict set of rules.

#### Traditional Parser Combinators

A parser is often represented by a function (`parse`), which takes a (mutable) reference to (out our case) `ParserState` and returns an `OK` or `ERR`.
For instance, you could define a sequence by taking an array of other parsers and calling `parse` on each of them in order.
If you ever run into an `ERR` you then just return an `ERR` (there are additional complications about how you reset the state after a failure).
These kinds of parsers are only suitable in certain circumstances, as often when one error is encontered, no syntax tree is generated.
This would be useless, for instance in a languages IDE support.

#### Gibberish Parsers

The API we use doesn't just have `OK` and `ERR`.

- OK: Is represented by 0
- ERR: Is represented by 1
- BREAK(index): Is every other value, with 2 being BREAK(EOF)

The idea is that when a parser executes `parse` if the first token is parsed correctly then it will (eventually) return `OK` and will try and use this parser until:
A) It completes successfully
B) A `BREAK` is encountered
Any currently skipped tokens are bumped as skipped and ignored from this logic.
When the first token that a token tries to parse is a `BREAK(])` (any peak of a delim succeeds), it will immediatlly return that BREAK (Unless the break was created within this parser i.e. the break index is greater than the max index when `parse` started)
Otherwise the token is bumped as unexpected.

#### Sequence

For instance you can define the following sequence parser in gibberish.

```
l_bracket + ident + r_bracket
```

If you parsed the l_bracket correctly, and were trying to parse the ident, there would also be a r_bracket delim in the stack.
This would mean if you were given: "[]" the sequence parser could tell that it hit the ']' before it ever found an 'ident' so it can say the ident is missing.
However if you were given `[123 abc]` the '123' would just be seen as an error and not a break, so the parser can mark it as unexpected and keep trying to parse the ident it was looking for.

#### Named

A named parser is made of an inner parser and a name. All it does is group the contents of the inner parser in a group with provided name

Parsers are defined in Gibberish like the following

```
parser <name> = <expr>;
```

e.g.

```
parser _item = string | num;
parser items = _item.sep_by(comma);
```

When you define a parser with name a not starting with '\_' it tells the compiler to make the parser into a `Named` parser.

#### Choice

The choice parser will try to parse each option until one succeeds.

```
parser _expr = num | string | object | array;
```

#### Repeated

The repeated parser will keep attempting to parse its `inner` parser until it reaches a `BREAK`.
It also pushes a `BREAK(inner)` when the parser starts (removed when finished). This means
that if, while parsing `inner` you run into the start of another `inner` it can break out of the first one and
start parsing the next, creating missing errors along the way.

```
parser root = stmt.repeated();
```

As an example if `stmt` here was an SQL statment.

```sql
select something from
delete
```

The first statement would break when it hits the 'delete' token, and would creating missing 'table_name' and ';'.
The second statement would break at EOF (also raising missing errors)

#### SepBy

Is similar to `Repeated` but allows you to seperate an `item` parser by a `sep` parser.

```
parser list = item.sep_by(comma);
```

Repeated will push two delims into the state when it starts, for the `item` and the `sep`.
If `BREAK(item)` is hit while trying to parse a `sep` then we can create a missing sep error and recover.
If `BREAK(sep)` is hit while trying to parse an `item` then we can create a missing item error and recover.
The delims also allow `item` and `sep` parsers to recover against eachother.

#### Skip

Insert a `token` into the skipped set when it starts and removes it when it finishes.

```
parser root = stmt
  .repeated()
  .skip(whitespace);
```

This will skip all whitespace tokens when parsing

#### Unskip

Oppoisite of skip

#### Labelled

Changes the `expected` generated when the parser is missing

#### Example

A json parser in Gibberish would look like this:

```
keyword true;
keyword false;
token whitespace = "[ \t\n\f]+";
token str = "\"[^\"]*\"";
token int = "[0-9]+";
token colon = ":";
token comma = ",";
token l_bracket = "\[";
token r_bracket = "\]";
token l_brace = "\{";
token r_brace = "\}";

parser string = str;
parser num = int;
parser bool = true | false;
parser array = _expr.sep_by(comma).delim_by(l_bracket, r_bracket);
parser field = str + colon + _expr;
parser object = field.sep_by(comma).delim_by(l_brace, r_brace);
parser _expr = (object | array | string | num | bool).labelled(expr);

parser root = _expr.skip(whitespace)

```

##### Success

Parsing:

```json
{
  "name": "Hello, World!",
  "data": [123, true]
}
```

```
root
  object
    l_brace: "{"@0..1
    whitespace: "\n  "@1..4
    field
      str: "\"name\""@4..10
      colon: ":"@10..11
      whitespace: " "@11..12
      string
        str: "\"Hello, World!\""@12..27
    comma: ","@27..28
    whitespace: "\n  "@28..31
    field
      str: "\"data\""@31..37
      colon: ":"@37..38
      whitespace: " "@38..39
      array
        l_bracket: "["@39..40
        num
          int: "123"@40..43
        comma: ","@43..44
        whitespace: " "@44..45
        bool
          true: "true"@45..49
        r_bracket: "]"@49..50
    whitespace: "\n"@50..51
    r_brace: "}"@51..52
  whitespace: "\n"@52..53
```

##### Missing Comma

Parsing:

```json
{
  "name": "Hello, World!"
  "data": [123, true]
}
```

```
root
  object
    l_brace: "{"@0..1
    whitespace: "\n  "@1..4
    field
      str: "\"name\""@4..10
      colon: ":"@10..11
      whitespace: " "@11..12
      string
        str: "\"Hello, World!\""@12..27
    whitespace: "\n  "@27..30
    Missing: comma
    field
      str: "\"data\""@30..36
      colon: ":"@36..37
      whitespace: " "@37..38
      array
        l_bracket: "["@38..39
        num
          int: "123"@39..42
        comma: ","@42..43
        whitespace: " "@43..44
        bool
          true: "true"@44..48
        r_bracket: "]"@48..49
    whitespace: "\n"@49..50
    r_brace: "}"@50..51
  whitespace: "\n"@51..52
```

##### Very Broken

Parsing:

```json
{
  "name": ,
  "data": [123,
```

```
root
  object
    l_brace: "{"@0..1
    whitespace: "\n  "@1..4
    field
      str: "\"name\""@4..10
      colon: ":"@10..11
      whitespace: " "@11..12
      Missing: expr
    comma: ","@12..13
    whitespace: "\n  "@13..16
    field
      str: "\"data\""@16..22
      colon: ":"@22..23
      whitespace: " "@23..24
      array
        l_bracket: "["@24..25
        num
          int: "123"@25..28
        comma: ","@28..29
        whitespace: " \n"@29..31
        Missing: expr
        Missing: r_bracket
    Missing: r_brace
```
