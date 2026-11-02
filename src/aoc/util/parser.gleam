import pears
import pears/chars
import pears/combinators

pub type Parser(a) =
  pears.Parser(String, a)

pub fn replace(p: Parser(a), b: b) -> Parser(b) {
  combinators.replace(p, b)
}

pub fn drop(p: Parser(a), f: fn() -> Parser(b)) -> Parser(b) {
  combinators.skip_then(p, combinators.lazy(f))
}

pub fn keep(pf: Parser(fn(a) -> b), pa: Parser(a)) -> Parser(b) {
  use f <- combinators.then(pf)
  use a <- combinators.then(pa)
  combinators.succeed(f(a))
}

pub fn skip(pa: Parser(a), pb: Parser(b)) -> Parser(a) {
  combinators.then_skip(pa, pb)
}

pub fn int() -> Parser(Int) {
  chars.natural()
}

pub fn signed_int() -> Parser(Int) {
  use mult <- combinators.then(
    combinators.choice([
      chars.string("+") |> replace(1),
      chars.string("-") |> replace(-1),
      combinators.succeed(1),
    ]),
  )
  use i <- combinators.then(int())

  combinators.succeed(mult * i)
}

pub fn go(str: String, p: Parser(a)) -> a {
  let assert Ok(parsed) = pears.parse_string(str, p)
  parsed.value
}
