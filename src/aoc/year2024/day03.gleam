import aoc/util/parser.{type Parser}
import gleam/list
import party

type Token {
  Mul(a: Int, b: Int)
  Do
  Dont
}

fn mul_p() -> Parser(Token) {
  party.return(fn(a) { fn(b) { Mul(a:, b:) } })
  |> parser.skip(party.string("mul("))
  |> parser.keep(parser.int())
  |> parser.skip(party.string(","))
  |> parser.keep(parser.int())
  |> parser.skip(party.string(")"))
}

fn token_p() -> Parser(Token) {
  party.choice([
    party.string("don't()") |> parser.replace(Dont),
    party.string("do()") |> parser.replace(Do),
    mul_p(),
    party.lazy(fn() { party.seq(party.any_char(), token_p()) }),
  ])
}

fn tokens_p() -> Parser(List(Token)) {
  party.many1(token_p())
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
