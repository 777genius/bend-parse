import Base
import ../parse.bend as P

def ParseTest.ok(name: String, pass: Bool) -> IO(Unit):
  match pass:
    case True{}:
      IO.pure(Unit, Unit{})
    case False{}:
      IO.die(Unit, 1, name)

def ParseTest.is_fail_u(
  name: String, r: Result<&2, &2, P.Parse.Error, Unit>
) -> IO(Unit):
  match r:
    case Fail{_}:
      IO.pure(Unit, Unit{})
    case Done{_}:
      IO.die(Unit, 1, name)

def ParseTest.is_fail_dec(
  name: String, r: Result<&2, &2, P.Parse.Error, P.Parse.Dec>
) -> IO(Unit):
  match r:
    case Fail{_}:
      IO.pure(Unit, Unit{})
    case Done{_}:
      IO.die(Unit, 1, name)

def ParseTest.is_fail_cur(
  name: String, r: Result<&2, &2, P.Parse.Error, P.Parse.Cur>
) -> IO(Unit):
  match r:
    case Fail{_}:
      IO.pure(Unit, Unit{})
    case Done{_}:
      IO.die(Unit, 1, name)

def ParseTest.dec(
  name: String, r: Result<&2, &2, P.Parse.Error, P.Parse.Dec>, want: U32
) -> IO(Unit):
  match r:
    case Fail{_}:
      IO.die(Unit, 1, name)
    case Done{P.Dec{n, _}}:
      ParseTest.ok(name, U32.is_eq(n, want))

def ParseTest.fin_ok(
  name: String, r: Result<&2, &2, P.Parse.Error, Unit>
) -> IO(Unit):
  match r:
    case Fail{_}:
      IO.die(Unit, 1, name)
    case Done{_}:
      IO.pure(Unit, Unit{})

def ParseTest.cur_ok(
  name: String, r: Result<&2, &2, P.Parse.Error, P.Parse.Cur>
) -> IO(Unit):
  match r:
    case Fail{_}:
      IO.die(Unit, 1, name)
    case Done{_}:
      IO.pure(Unit, Unit{})

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- ParseTest.fin_ok("finish_empty", P.Parse.finish(P.Parse.start("")))
    Unit <- ParseTest.is_fail_u("finish_x", P.Parse.finish(P.Parse.start("x")))
    Unit <- ParseTest.dec("digit_7", P.Parse.ascii_digit(P.Parse.start("7")), 7)
    Unit <- ParseTest.is_fail_dec("digit_a", P.Parse.ascii_digit(P.Parse.start("a")))
    Unit <- ParseTest.dec(
      "year", P.Parse.read_fixed_decimal(P.Parse.start("2026"), 4n, 9999), 2026
    )
    Unit <- ParseTest.is_fail_dec(
      "ov", P.Parse.read_fixed_decimal(P.Parse.start("13"), 2n, 12)
    )
    Unit <- ParseTest.cur_ok(
      "lit", P.Parse.expect_literal(P.Parse.start("T15"), "T")
    )
    Unit <- ParseTest.cur_ok(
      "char", P.Parse.expect_char(P.Parse.start("-01"), '-')
    )
    Unit <- ParseTest.is_fail_cur(
      "space_T", P.Parse.expect_char(P.Parse.start(" 15"), 'T')
    )
    IO.print("ok")
