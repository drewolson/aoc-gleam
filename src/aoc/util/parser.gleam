import pears
import pears/chars
import pears/combinators

pub type Parser(a) =
  pears.Parser(String, a)

pub fn drop(p: Parser(a), f: fn() -> Parser(b)) -> Parser(b) {
  combinators.skip_then(p, combinators.lazy(f))
}

pub fn signed_int() -> Parser(Int) {
  use mult <- combinators.then(
    combinators.choice([
      chars.string("+") |> combinators.replace(1),
      chars.string("-") |> combinators.replace(-1),
      combinators.succeed(1),
    ]),
  )
  use i <- combinators.then(chars.natural())

  combinators.succeed(mult * i)
}

pub fn go(str: String, p: Parser(a)) -> a {
  let assert Ok(parsed) = pears.parse_string(str, p)
  parsed.value
}
