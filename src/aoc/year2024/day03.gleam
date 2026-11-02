import aoc/util/parser.{type Parser}
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import pears/chars
import pears/combinators

type Token {
  Mul(a: Int, b: Int)
  Do
  Dont
}

fn int() -> Parser(Int) {
  use digits <- combinators.try_map(combinators.many1(chars.digit()))

  case list.length(digits) > 3 {
    True -> Error("int too long")
    False ->
      digits
      |> string.concat
      |> int.parse
      |> result.replace_error("not an int")
  }
}

fn mul_p() -> Parser(Token) {
  use <- parser.drop(chars.string("mul("))
  use a <- combinators.then(int())
  use <- parser.drop(chars.string(","))
  use b <- combinators.then(int())
  use <- parser.drop(chars.string(")"))
  combinators.succeed(Mul(a:, b:))
}

fn token_p() -> Parser(Token) {
  combinators.choice([
    chars.string("don't()") |> combinators.replace(Dont),
    chars.string("do()") |> combinators.replace(Do),
    mul_p(),
    combinators.lazy(fn() {
      combinators.skip_then(combinators.any(), token_p())
    }),
  ])
}

fn tokens_p() -> Parser(List(Token)) {
  combinators.many1(token_p())
}

pub fn part1(input: String) -> Int {
  input
  |> parser.go(tokens_p())
  |> list.fold(0, fn(s, t) {
    case t {
      Mul(a:, b:) -> s + a * b
      _ -> s
    }
  })
}

pub fn part2(input: String) -> Int {
  let #(count, _) =
    input
    |> parser.go(tokens_p())
    |> list.fold(#(0, True), fn(p, t) {
      let #(count, go) = p
      case t {
        Dont -> #(count, False)
        Do -> #(count, True)
        Mul(a:, b:) if go -> #(count + a * b, go)
        _ -> p
      }
    })

  count
}
