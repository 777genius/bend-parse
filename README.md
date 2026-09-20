# bend-parse

Cursor, digits, and finish for [Bend 2](https://github.com/bendlang/bend). One file. Built for RFC 3339 in [bend-time](https://github.com/777genius/bend-time). Not a combinator library.

## Install

```python
import 0xe49a3e6521e1b71e55654a885f27bcc1/parse.bend as P
```

[parse](https://hub.bend-lang.com/0xe49a3e6521e1b71e55654a885f27bcc1/parse.bend) · [manifest](https://hub.bend-lang.com/0xe49a3e6521e1b71e55654a885f27bcc1/manifest)

This hash is v0.1.0. From this repo: `import ./parse.bend as P`.

## Example

```python
import Base
import ./parse.bend as P

def Readme.from_result(
  r: Result<&2, &2, P.Parse.Error, P.Parse.Dec>
) -> String:
  match r:
    case Done{P.Dec{n, _}}:
      U32.show(n)
    case Fail{_}:
      "fail"

def main() -> IO(Unit):
  IO.print(
    Readme.from_result(
      P.Parse.read_fixed_decimal(P.Parse.start("2026"), 4n, 9999)
    )
  )
```

Prints `2026`. Copy: [`examples/readme.bend`](examples/readme.bend).

## API

```text
Parse.start(text) -> Cur
Parse.peek(cur) -> Maybe<Char>
Parse.expect_char(cur, c) -> Result<Cur, Parse.Error>
Parse.expect_literal(cur, pat) -> Result<Cur, Parse.Error>
Parse.ascii_digit(cur) -> Result<Dec, Parse.Error>
Parse.read_fixed_decimal(cur, count, max) -> Result<Dec, Parse.Error>
Parse.finish(cur) -> Result<Unit, Parse.Error>
```

- `Cur` is remaining input plus a 0-based character offset.
- `Dec` is `{value, cur}` after a successful numeric read.
- `read_fixed_decimal` reads exactly `count` ASCII digits; the value must be `<= max` or the result is `Overflow`. Overflow is checked before `* 10`.
- `finish` requires the rest of the input to be empty. Prefix parses stop before `finish`.
- No whitespace skip. A space is an unexpected character.

## Proofs

Closed cursor/digit/year fixtures are **proved**. Overflow and unexpected characters are **tested**. Table: [docs/proof-status.md](docs/proof-status.md).

## Check

Bend **2.0.5** (`0b7e2b11`), bun 1.3.11, clang 14+. Pin: [docs/compatibility.md](docs/compatibility.md).

```sh
./tools/e2e
```

## License

Apache-2.0. Copyright 2026 Илия.
