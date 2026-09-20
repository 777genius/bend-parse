# Parse proof status

Domain: ASCII cursor over Bend `String`. No combinators.

| Claim | Status | Domain |
|---|---|---|
| `start("")` empty cursor | proved | empty |
| `peek("1") = '1'` | proved | closed |
| `finish("")` succeeds | proved | empty |
| `ascii_digit("2") = 2` | proved | closed |
| `read_fixed_decimal("2026", 4, 9999) = 2026` | proved | closed |
| `13` with max `12` is `Overflow` | tested | |
| non-digit / extra / missing `T` fail | tested | |

No `@unsafe`. No `F32`. Payload walks do not call Base `String.length` /
`String.split` / `List.length`.
