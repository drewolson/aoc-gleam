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

pub fn do(
  pa: party.Parser(a, e),
  f: fn(a) -> party.Parser(b, e),
) -> party.Parser(b, e) {
  party.do(pa, f)
}

pub fn replace(p: party.Parser(a, e), b: b) -> party.Parser(b, e) {
  party.map(p, fn(_) { b })
}

pub fn keep(
  pf: party.Parser(fn(a) -> b, e),
  pa: party.Parser(a, e),
) -> party.Parser(b, e) {
  use f <- party.do(pf)
  use a <- party.do(pa)
  party.return(f(a))
}

pub fn skip(
  pa: party.Parser(a, e),
  pb: party.Parser(b, e),
) -> party.Parser(a, e) {
  use a <- party.do(pa)
  use _ <- party.do(pb)
  party.return(a)
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
