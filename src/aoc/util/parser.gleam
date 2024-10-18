import gleam/int
import gleam/result
import party

pub type Parser(a) =
  party.Parser(a, String)

pub fn keep(
  pa: party.Parser(a, e),
  pb: party.Parser(b, e),
) -> party.Parser(b, e) {
  party.seq(pa, pb)
}

pub fn skip(
  pa: party.Parser(a, e),
  pb: party.Parser(b, e),
) -> party.Parser(a, e) {
  use a <- party.do(pa)
  use _ <- party.do(pb)
  party.return(a)
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
