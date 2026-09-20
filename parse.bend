import Base

type Parse.Cur is Data:
  Cur{rest: String, off: Nat}

type Parse.Error is Data:
  Unexpected{offset: Nat, char: Char}
  Eof{offset: Nat}
  Overflow{offset: Nat}
  Extra{offset: Nat, char: Char}

type Parse.St is Data:
  StOk{}
  StBad{c: Char}
  StOv{}

type Parse.Dec is Data:
  Dec{value: U32, cur: Parse.Cur}

def Parse.start(text: String) -> Parse.Cur:
  Cur{text, 0n}

def Parse.peek.s(s: String) -> Maybe<&2, Char>:
  match s:
    case SNil{}:
      None{}
    case SCon{+h, _}:
      Some{h}

def Parse.peek(cur: Parse.Cur) -> Maybe<&2, Char>:
  match cur:
    case Cur{rest, _}:
      Parse.peek.s(rest)

def Parse.expect_char.eq(
  t: String, off: Nat, h: Char, eq: Bool
) -> Result<&2, &2, Parse.Error, Parse.Cur>:
  match eq:
    case True{}:
      Done{Cur{t, 1n+off}}
    case False{}:
      Fail{Unexpected{off, h}}

def Parse.expect_char.s(
  s: String, off: Nat, +want: Char
) -> Result<&2, &2, Parse.Error, Parse.Cur>:
  match s:
    case SNil{}:
      Fail{Eof{off}}
    case SCon{+h, t}:
      Parse.expect_char.eq(t, off, h, Char.is_eq(h, want))

def Parse.expect_char(
  cur: Parse.Cur, +want: Char
) -> Result<&2, &2, Parse.Error, Parse.Cur>:
  match cur:
    case Cur{rest, off}:
      Parse.expect_char.s(rest, off, want)

def Parse.expect_literal.go(
  s: String, p: String, eq: Bool, h: Char, off: Nat
) -> Result<&2, &2, Parse.Error, Parse.Cur>:
  match s p eq:
    case _ _ False{}:
      Fail{Unexpected{off, h}}
    case _ SNil{} True{}:
      Done{Cur{s, 1n+off}}
    case SNil{} SCon{_, _} True{}:
      Fail{Eof{1n+off}}
    case SCon{+h2, t} SCon{ph, pt} True{}:
      Parse.expect_literal.go(t, pt, Char.is_eq(h2, ph), h2, 1n+off)

def Parse.expect_literal.start(
  s: String, p: String, off: Nat
) -> Result<&2, &2, Parse.Error, Parse.Cur>:
  match s p:
    case _ SNil{}:
      Done{Cur{s, off}}
    case SNil{} SCon{_, _}:
      Fail{Eof{off}}
    case SCon{+h, t} SCon{ph, pt}:
      Parse.expect_literal.go(t, pt, Char.is_eq(h, ph), h, off)

def Parse.expect_literal(
  cur: Parse.Cur, pat: String
) -> Result<&2, &2, Parse.Error, Parse.Cur>:
  match cur:
    case Cur{rest, off}:
      Parse.expect_literal.start(rest, pat, off)

def Parse.ascii_digit.val(
  +h: Char, t: String, off: Nat, dig: Bool
) -> Result<&2, &2, Parse.Error, Parse.Dec>:
  match dig:
    case False{}:
      Fail{Unexpected{off, h}}
    case True{}:
      Done{Dec{(Char.to_u32(h) - Char.to_u32('0') : U32), Cur{t, 1n+off}}}

def Parse.ascii_digit.s(
  s: String, off: Nat
) -> Result<&2, &2, Parse.Error, Parse.Dec>:
  match s:
    case SNil{}:
      Fail{Eof{off}}
    case SCon{+h, t}:
      Parse.ascii_digit.val(h, t, off, Char.is_digit(h))

def Parse.ascii_digit(
  cur: Parse.Cur
) -> Result<&2, &2, Parse.Error, Parse.Dec>:
  match cur:
    case Cur{rest, off}:
      Parse.ascii_digit.s(rest, off)

def Parse.acc.ok(+acc: U32, +d: U32, +max: U32) -> Bool:
  Nat.is_le(Nat.add(Nat.mul(U32.to_nat(acc), 10n), U32.to_nat(d)), U32.to_nat(max))

def Parse.nacc(+acc: U32, +h: Char) -> U32:
  U32.add(U32.mul(acc, 10), (Char.to_u32(h) - Char.to_u32('0') : U32))

def Parse.st.ov(+acc: U32, +d: U32, +max: U32, ok: Bool) -> Parse.St:
  match ok:
    case False{}:
      StOv{}
    case True{}:
      StOk{}

def Parse.st.of2(+acc: U32, +h: Char, +max: U32, dig: Bool) -> Parse.St:
  match dig:
    case False{}:
      StBad{h}
    case True{}:
      Parse.st.ov(
        acc, (Char.to_u32(h) - Char.to_u32('0') : U32), max,
        Parse.acc.ok(acc, (Char.to_u32(h) - Char.to_u32('0') : U32), max)
      )

def Parse.st.of(+acc: U32, +h: Char, +max: U32) -> Parse.St:
  Parse.st.of2(acc, h, max, Char.is_digit(h))

def Parse.read_fixed.go(
  s: String, n: Nat, +acc: U32, off: Nat, st: Parse.St, +max: U32
) -> Result<&2, &2, Parse.Error, Parse.Dec>:
  match s n st:
    case _ _ StBad{c}:
      Fail{Unexpected{off, c}}
    case _ _ StOv{}:
      Fail{Overflow{off}}
    case _ 0n StOk{}:
      Done{Dec{acc, Cur{s, off}}}
    case SNil{} 1n++p StOk{}:
      Fail{Eof{off}}
    case SCon{+h, t} 1n++p StOk{}:
      Parse.read_fixed.go(
        t, p, Parse.nacc(acc, h), 1n+off, Parse.st.of(acc, h, max), max
      )

def Parse.read_fixed_decimal(
  cur: Parse.Cur, count: Nat, max: U32
) -> Result<&2, &2, Parse.Error, Parse.Dec>:
  match cur:
    case Cur{rest, off}:
      Parse.read_fixed.go(rest, count, 0, off, StOk{}, max)

def Parse.finish.s(
  s: String, off: Nat
) -> Result<&2, &2, Parse.Error, Unit>:
  match s:
    case SNil{}:
      Done{Unit{}}
    case SCon{h, _}:
      Fail{Extra{off, h}}

def Parse.finish(
  cur: Parse.Cur
) -> Result<&2, &2, Parse.Error, Unit>:
  match cur:
    case Cur{rest, off}:
      Parse.finish.s(rest, off)
