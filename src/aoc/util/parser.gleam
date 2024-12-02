import gleam/int
import gleam/result
import party

pub type Parser(a) =
  party.Parser(a, String)

pub fn drop(
  pa: party.Parser(a, e),
  f: fn() -> party.Parser(b, e),
) -> party.Parser(b, e) {
  use _ <- party.do(pa)
  f()
}

pub fn replace(p: party.Parser(a, e), b: b) -> party.Parser(b, e) {
  party.map(p, fn(_) { b })
}

pub fn int() -> party.Parser(Int, String) {
  use digits <- party.try(party.digits())

  digits
  |> int.parse
  |> result.replace_error("Not a valid integer")
}

pub fn signed_int() -> party.Parser(Int, String) {
  use mult <- party.do(
    party.choice([
      party.string("+") |> replace(1),
      party.string("-") |> replace(-1),
      party.return(1),
    ]),
  )
  use i <- party.do(int())

  party.return(mult * i)
}

pub fn go(str: String, p: Parser(a)) -> a {
  let assert Ok(v) = party.go(p, str)
  v
}
