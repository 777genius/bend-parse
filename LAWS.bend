import Base
import ./parse.bend as P

law start_empty:
  {P.Parse.start("") == P.Cur{SNil{}, 0n} : P.Parse.Cur}

law peek_1:
  {P.Parse.peek(P.Parse.start("1")) == Some{'1'} : Maybe<&2, Char>}

law finish_empty:
  {
    P.Parse.finish(P.Parse.start("")) == Done{Unit{}}
    : Result<&2, &2, P.Parse.Error, Unit>
  }

law digit_2:
  {
    P.Parse.ascii_digit(P.Parse.start("2")) == Done{P.Dec{2, P.Cur{SNil{}, 1n}}}
    : Result<&2, &2, P.Parse.Error, P.Parse.Dec>
  }

law year_2026:
  {
    P.Parse.read_fixed_decimal(P.Parse.start("2026"), 4n, 9999) ==
      Done{P.Dec{2026, P.Cur{SNil{}, 4n}}}
    : Result<&2, &2, P.Parse.Error, P.Parse.Dec>
  }
