import Base
import ../parse.bend as P

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
